;; p -> post id, v -> page id, d -> tag id
(defun string->number (str)
  (let ((stream-name (gensym)))
    (with-input-from-string (stream-name str)
      (read stream-name))))

(easy-routes:defroute main ("/") (p v)
  (if (null p)
      (get-main-page-data (if (null v) 0 (string->number v)))
      (get-post-page-data p)))

(easy-routes:defroute about ("/about") ()
  (easy-routes:redirect "/?p=2"))

(easy-routes:defroute cl-blog ("/cl-blog") ()
  (easy-routes:redirect "/?p=3"))

(easy-routes:defroute login ("/login") (failedp outdatedp)
  (if (get-user-loginp)
      (easy-routes:redirect "/admin")
      (render-login-page failedp outdatedp)))

(easy-routes:defroute admin ("/admin") ()
  (if (get-user-loginp)
      (get-admin-page-data)
      (easy-routes:redirect "/login?outdatedp=t")))

(easy-routes:defroute modify ("/modify") (p)
  (if (get-user-loginp)
      (get-modify-page-data p)
      (easy-routes:redirect "/login?outdatedp=t")))

(easy-routes:defroute action-login ("/login" :method :post) (username password)
  (set-user-login username password))

(easy-routes:defroute action-logout ("/logout") ()
  (set-user-logout))

(easy-routes:defroute action-add-post ("/add" :method :post) (title content)
  (if (get-user-loginp)
      (set-add-post-data title content)
      (easy-routes:redirect "/login?outdated=t")))

(easy-routes:defroute action-delete-post ("/delete") (p)
  (if (get-user-loginp)
      (set-delete-post-data p)
      (easy-routes:redirect "/login?outdated=t")))

(easy-routes:defroute action-modify-post ("/modify" :method :post) (p title content)
  (if (get-user-loginp)
      (set-modify-post-data p title content)))

(hunchentoot:define-easy-handler (upload :uri "/upload") (file)
  (when (and (get-user-loginp) (not (null file)))
    (set-upload-file-data file))
  (easy-routes:redirect "/admin"))

(push (hunchentoot:create-folder-dispatcher-and-handler
       "/static/"
       (merge-pathnames "static/"))
      hunchentoot:*dispatch-table*)
