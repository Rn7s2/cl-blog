(ql:quickload 'sqlite)

(defvar *db-path* (merge-pathnames "model/blog.db"))

(defmacro sql-execute-sql (sql &rest params)
  (let ((db-name (gensym)))
    `(sqlite:with-open-database (,db-name *db-path*)
       (sqlite:execute-non-query ,db-name ,sql ,@params))))

(defmacro sql-query-single-value (sql &rest params)
  (let ((db-name (gensym)))
    `(sqlite:with-open-database (,db-name *db-path*)
       (sqlite:execute-single ,db-name ,sql ,@params))))

(defmacro sql-query-single-post (sql prepare-function &rest params)
  (let ((db-name (gensym)))
    `(funcall ,prepare-function
              (car (sqlite:with-open-database (,db-name *db-path*)
                     (sqlite:execute-to-list ,db-name ,sql ,@params))))))

(defmacro sql-query-all-posts (sql prepare-function &rest params)
  (let ((db-name (gensym)))
    `(mapcar ,prepare-function
             (sqlite:with-open-database (,db-name *db-path*)
               (sqlite:execute-to-list ,db-name ,sql ,@params)))))
