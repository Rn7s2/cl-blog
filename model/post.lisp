(ql:quickload '(3bmd 3bmd-ext-code-blocks))

(setf 3bmd-code-blocks:*code-blocks* t)
(setf 3bmd-code-blocks:*renderer* :nohighlight)

(defun markdown->html (md)
  (when (not (null md))
    (let ((stream-name (gensym)))
      (with-output-to-string (stream-name)
        (3bmd:parse-string-and-print-to-stream md stream-name)))))

(defun get-main-page-data (v)
  (flet ((make-abstract (str)
           (subseq str 0 (search "<hr" str))))
    (let ((posts (sql-query-all-posts "select * from posts"
                                      (lambda (item)
                                        `(:id ,(first item)
                                          :title ,(second item)
                                          :date ,(third item)
                                          :content ,(make-abstract
                                                     (markdown->html
                                                      (fourth item))))))))
      (render-main-page (get-user-loginp) posts v))))

(defun get-list-page-data ()
  (let* ((posts (sql-query-all-posts "select id,title,date from posts"
                                     (lambda (item)
                                       (list :id (first item)
                                             :title (second item)
                                             :date (third item))))))
    (render-list-page posts)))

(defun get-post-page-data (p)
  (let ((post (sql-query-single-post "select * from `posts` where `id`=?"
                                     (lambda (item)
                                       `(:id ,(first item)
                                         :title ,(second item)
                                         :date ,(third item)
                                         :content ,(markdown->html
                                                    (fourth item))))
                                     p)))
    (if (null (getf post :title))
        (easy-routes:redirect "/")
        (render-post-page (get-user-loginp) post))))

(defun get-admin-page-data ()
  (let* ((posts (sql-query-all-posts "select id,title,date from posts"
                                     (lambda (item)
                                       (list :id (first item)
                                             :title (second item)
                                             :date (third item))))))
    (render-admin-page (get-user-loginp) posts)))

(defun get-modify-page-data (p)
  (let ((post (sql-query-single-post "select id,title,content from posts where id=?"
                                     (lambda (item)
                                       `(:id ,(first item)
                                         :title ,(second item)
                                         :content ,(third item)))
                                     p)))
    (render-modify-page (get-user-loginp) post)))

(defun set-add-post-data (title content)
  (when (and (> (length title) 0) (> (length content) 0))
    (sql-execute-sql "insert into posts(title,date,content) values (?,date('now'),?)"
                     title
                     content))
  (easy-routes:redirect "/"))

(defun set-delete-post-data (p)
  (sql-execute-sql "delete from posts where id=?" p)
  (easy-routes:redirect "/admin"))

(defun set-modify-post-data (p title content)
  (when (and (not (null p)) (not (null title)) (not (null content)))
    (sql-execute-sql "update `posts` set `title`=?,`date`=date('now'),`content`=? where `id`=?"
                     title
                     content
                     p))
  (easy-routes:redirect (format nil "/?p=~a" p)))
