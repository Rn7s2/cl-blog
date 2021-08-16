(load "~/.quicklisp/setup.lisp")
(ql:quickload 'sqlite)

(defvar *db* (sqlite:connect "blog.db"))

(sqlite:execute-non-query *db* "create table posts(id integer primary key autoincrement not null, title text not null, date text not null, content text not null)")
(sqlite:execute-non-query *db* "create table users(id integer primary key autoincrement not null, username text not null, password text not null)")
(sqlite:execute-non-query *db* "insert into users (username, password) VALUES ('rn7s2', 'PBKDF2$SHA256:20000$4b58a127797e19ec14a2522d4643fe6d$f4185e6242fa2a4bbd4cebd90a63f37342531b98a5081adeace4e8437866a76e')")

(sqlite:disconnect *db*)
