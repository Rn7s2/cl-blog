(load "~/.quicklisp/setup.lisp")
(ql:quickload '(3bmd sqlite cl-pass easy-routes hunchentoot html-template 3bmd-ext-code-blocks))

(setf 3bmd-code-blocks:*code-blocks* t)
(setf html-template:*string-modifier* #'cl:identity)
(defvar *db-path* "blog.db")
(defvar *abstract-length* 100)
(defvar *server* (make-instance 'easy-routes:easy-routes-acceptor :address "127.0.0.1" :port 3000))

(defun parse-template (file-path values)
  (let ((stream-name (gensym)))
    (cl:with-output-to-string (stream-name)
      (html-template:fill-and-print-template file-path values :stream stream-name))))

(defun markdown->html (str)
  (cl:with-output-to-string (out-stream)
    (3bmd:parse-string-and-print-to-stream str out-stream)))

(defun get-abstract (str)
  (if (> (length str) *abstract-length*)
      (subseq str 0 *abstract-length*)
      str))

(defmacro get-single-value (sql &rest params)
  (let ((db-name (gensym)))
    `(sqlite:with-open-database (,db-name *db-path*)
       (sqlite:execute-single ,db-name ,sql ,@params))))

(defmacro get-post (sql prepare-function &rest params)
  (let ((db-name (gensym)))
    `(funcall ,prepare-function
              (car (sqlite:with-open-database (,db-name *db-path*)
                     (sqlite:execute-to-list ,db-name ,sql ,@params))))))

(defmacro get-posts-list (sql prepare-function &optional reverse &rest params)
  (let ((db-name (gensym)))
    (if reverse
        `(reverse (mapcar ,prepare-function
                          (sqlite:with-open-database (,db-name *db-path*)
                            (sqlite:execute-to-list ,db-name ,sql ,@params))))
        `(mapcar ,prepare-function
                 (sqlite:with-open-database (,db-name *db-path*)
                   (sqlite:execute-to-list ,db-name ,sql ,@params))))))

(defmacro execute-sql (sql &rest params)
  (let ((db-name (gensym)))
    `(sqlite:with-open-database (,db-name *db-path*)
       (sqlite:execute-non-query ,db-name ,sql ,@params))))

(defun login-p ()
  (not (eql hunchentoot:*session* nil)))

(easy-routes:defroute index ("/") (p)
  (if (eql p nil)
      (let ((posts (get-posts-list "select * from posts"
                                   (lambda (item) `(:id ,(first item)
                                                    :title ,(second item)
                                                    :date ,(third item)
                                                    :content ,(get-abstract
                                                               (fourth item)))) t)))
        (parse-template #p"index.tmpl" `(:loginp ,(login-p) :posts ,posts)))
      (let ((post (get-post "select * from `posts` where `id`=?"
                            (lambda (item)
                              `(:id ,(first item)
                                :title ,(second item)
                                :date ,(third item)
                                :content ,(markdown->html (fourth item)))) p)))
        (if (eql (first post) nil)
            (easy-routes:redirect "/")
            (parse-template #p"post.tmpl" `(:loginp ,(login-p) ,@post))))))

(easy-routes:defroute about ("/about") ()
  (easy-routes:redirect "/?p=2"))

(easy-routes:defroute login ("/login") (failedp outdatedp)
  (if (login-p)
      (easy-routes:redirect "/admin")
      (parse-template #p"login.tmpl" `(:failedp ,failedp :outdatedp ,outdatedp))))

(easy-routes:defroute admin ("/admin") ()
  (if (login-p)
      (let* ((posts (get-posts-list "select id,title,date from posts"
                                    (lambda (item)
                                      (list :id (first item)
                                            :title (second item)
                                            :date (third item))) t)))
        (parse-template #p"admin.tmpl" `(:loginp ,(login-p) :posts ,posts)))
      (easy-routes:redirect "/login?outdatedp=t")))

(easy-routes:defroute modify-post ("/modify") (p)
  (if (login-p)
      (let ((post (get-post "select id,title,content from posts where id=?"
                            (lambda (item)
                              `(:id ,(first item)
                                :title ,(second item)
                                :content ,(third item))) p)))
        (parse-template #p"modify.tmpl" `(:loginp ,(login-p) ,@post)))
      (easy-routes:redirect "/admin")))

(easy-routes:defroute handle-login ("/login" :method :post) (username password)
  (if (login-p)
      (easy-routes:redirect "/admin")
      (labels ((post-login ()
                 (hunchentoot:start-session)
                 (easy-routes:redirect "/admin"))
               (verify (username password)
                 (let ((password-hash
                         (get-single-value "select password from users where username=?" username)))
                   (if (or (eql nil password-hash) (not (cl-pass:check-password password password-hash)))
                       (easy-routes:redirect "/login?failedp=t")
                       (post-login)))))
        (if (and (> (length username) 0) (> (length password) 0))
            (verify username password)
            (easy-routes:redirect "/login?failedp=t")))))

(easy-routes:defroute handle-logout ("/logout") ()
  (hunchentoot:remove-session hunchentoot:*session*)
  (easy-routes:redirect "/"))

(easy-routes:defroute handle-add-post ("/add" :method :post) (title content)
  (if (login-p)
      (progn
        (when (and (> (length title) 0) (> (length content) 0))
          (execute-sql "insert into posts(title,date,content) values (?,date('now'),?)" title content))
        (easy-routes:redirect "/admin"))
      (easy-routes:redirect "/login?outdated=t")))

(easy-routes:defroute handle-delete-post ("/delete") (p)
  (if (login-p)
      (execute-sql "delete from posts where id=?" p))
  (easy-routes:redirect "/admin"))

(easy-routes:defroute handle-modify-post ("/modify" :method :post) (p title content)
  (when (and (login-p) (not (null p)) (not (null title)) (not (null content)))
    (execute-sql "update `posts` set `title`=?,`date`=date('now'),`content`=? where `id`=?"
                 title content p))
  (easy-routes:redirect "/admin"))

(defun launch ()
  (hunchentoot:start *server*))

(defun terminate ()
  (hunchentoot:stop *server*))

(launch)
