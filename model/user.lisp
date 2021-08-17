(ql:quickload 'cl-pass)

(defun get-user-loginp ()
  (not (null hunchentoot:*session*)))

(defun set-user-post-login ()
  (hunchentoot:start-session)
  (easy-routes:redirect "/admin"))

(defun set-user-login (username password)
  (let ((password-hash
          (sql-query-single-value "select password from users where username=?"
                                  username)))
    (if (or (null password-hash)
            (not (cl-pass:check-password password password-hash)))
        (easy-routes:redirect "/login?failedp=t")
        (set-user-post-login))))

(defun set-user-logout ()
  (hunchentoot:remove-session hunchentoot:*session*)
  (easy-routes:redirect "/"))
