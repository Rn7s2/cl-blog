(defun set-upload-file-data (file)
  (rename-file (car file)
               (merge-pathnames (concatenate 'string
                                             "static/upload/"
                                             (cadr file)))))
