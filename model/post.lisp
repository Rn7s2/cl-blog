(defun get-index-page-data ()
  (flet ((make-abstract (str)
           (subseq str 0 (search "<hr" str))))
    (let ((posts (sql-query-all-posts "select * from posts"
                                      (lambda (item)
                                        `(:id ,(first item)
                                          :title ,(second item)
                                          :date ,(third item)
                                          :content ,(make-abstract
                                                     (fourth item)))))))
      (render-index-page (get-user-loginp) posts))))

(defun get-post-page-data (p)
  (let ((post (sql-query-single-post "select * from `posts` where `id`=?"
                                     (lambda (item)
                                       `(:id ,(first item)
                                         :title ,(second item)
                                         :date ,(third item)
                                         :content ,(fourth item)))
                                     p)))
    (if (null (first post))
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
