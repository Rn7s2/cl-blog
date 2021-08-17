(load #p"~/.quicklisp/setup.lisp")
(ql:quickload '(hunchentoot easy-routes))

(defvar *server* (make-instance 'easy-routes:easy-routes-acceptor
                                :address "127.0.0.1"
                                :port 3000))

(load (merge-pathnames "view/view.lisp"))
(load (merge-pathnames "model/model.lisp"))
(load (merge-pathnames "controller/controller.lisp"))

(defun launch ()
  (hunchentoot:start *server*))

(defun terminate ()
  (hunchentoot:stop *server*))

(launch)
