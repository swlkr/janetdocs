(declare-project
  :name "janetdocs"
  :description ""
  :dependencies ["https://github.com/joy-framework/joy"
                 "https://github.com/joy-framework/http"]
  :author ""
  :license ""
  :url ""
  :repo "")

(declare-executable
  :name "janetdocs"
  :entry "main.janet")

(phony "server" []
  (os/shell "janet main.janet"))

(phony "watch" []
  (os/shell "find . -name '*.janet' | entr -r -d janet main.janet"))
