(declare-project
  :name "janetdocs"
  :description "JanetDocs is a community documentation site for the Janet programming language"
  :dependencies ["https://github.com/janet-lang/sqlite3"
                 "https://github.com/joy-framework/dotenv"
                 "https://github.com/joy-framework/http"
                 "https://github.com/joy-framework/joy"]

  :author "Sean Walker"
  :license "MIT"
  :url "https://janetdocs.com"
  :repo "https://github.com/swlkr/janetdocs")

(declare-executable
  :name "janetdocs"
  :entry "main.janet")

(phony "server" []
  (os/shell "janet main.janet"))

(phony "watch" []
  (os/shell "find . -name '*.janet' | entr -r -d janet main.janet"))
