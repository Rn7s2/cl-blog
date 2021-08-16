# cl-blog
A minimalism blog written in Common Lisp.

## Usage
0. Edit `create-db.lisp` and `*.tmpl` to customize your blog.
0. Load `create-db.lisp` to create a sqlite database.
0. Load `cl-blog.lisp` in REPL, and open `http://127.0.0.1:3000` in your broswer. You should be greeted with the index page.

### Deployment
You can use Apache mod_proxy. So you can run it as common user and not directly export it to port 80.

## Functions
- [x] Markdown
- [x] KaTeX
- [x] User login/logout
- [x] Add/delete posts
- [x] Abstract
- [ ] comment
- [ ] Tags
