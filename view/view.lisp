(ql:quickload 'html-template)

(setf html-template:*string-modifier* #'cl:identity)

(defvar *index-reverse-order* t)
(defvar *admin-reverse-order* t)
(defvar *index-posts-pre-page* 5)

(defun parse-template (file-path values)
  (let ((stream-name (gensym)))
    (cl:with-output-to-string (stream-name)
      (html-template:fill-and-print-template file-path
                                             values
                                             :stream stream-name))))

;; 暂时不支持分页
(defun render-index-page (loginp posts)
  (parse-template (merge-pathnames "view/index.tmpl")
                  `(:loginp ,loginp
                    :posts ,(if (null *index-reverse-order*)
                                posts
                                (reverse posts)))))

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

(defun render-modify-page (loginp post)
  (parse-template (merge-pathnames "view/modify.tmpl") `(:loginp ,loginp ,@post)))
