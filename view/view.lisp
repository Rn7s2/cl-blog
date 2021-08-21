(ql:quickload 'html-template)

(setf html-template:*string-modifier* #'cl:identity)

(defvar *main-reverse-order* t)
(defvar *admin-reverse-order* t)
(defvar *list-reverse-order* t)
(defvar *volume-size* 5)

(defun parse-template (file-path values)
  (let ((stream-name (gensym)))
    (cl:with-output-to-string (stream-name)
      (html-template:fill-and-print-template file-path
                                             values
                                             :stream stream-name))))

(defun select-volume (posts v)
  (let* ((begin (* v *volume-size*))
         (end (+ begin *volume-size*)))
    (if (>= begin (length posts))
        nil
        (if (>= end (length posts))
            (subseq posts begin (length posts))
            (subseq posts begin end)))))

(defun render-main-page (loginp posts v)
  (let ((total-volume (ceiling (/ (length posts) *volume-size*))))
    (if (>= v total-volume)
        (easy-routes:redirect "/")
        (parse-template (merge-pathnames "view/main.tmpl")
                        `(:loginp ,loginp
                          :posts ,(select-volume (if (null *main-reverse-order*)
                                                     posts
                                                     (reverse posts))
                                                 v)
                          :current-volume ,(+ v 1)
                          :total-volume ,total-volume)))))

(defun render-post-page (loginp post)
  (parse-template (merge-pathnames "view/post.tmpl")
                  `(:loginp ,loginp ,@post)))

(defun render-login-page (failedp outdatedp)
  (parse-template (merge-pathnames "view/login.tmpl")
                  `(:failedp ,failedp :outdatedp ,outdatedp)))

(defun render-admin-page (loginp posts)
  (parse-template (merge-pathnames "view/admin.tmpl")
                  `(:loginp ,loginp
                    :posts ,(if (null *admin-reverse-order*)
                                posts
                                (reverse posts)))))

(defun render-list-page (loginp posts)
  (parse-template (merge-pathnames "view/list.tmpl")
                  `(:posts ,(if (null *list-reverse-order*)
                                posts
                                (reverse posts)))))

(defun render-modify-page (loginp post)
  (parse-template (merge-pathnames "view/modify.tmpl") `(:loginp ,loginp ,@post)))
