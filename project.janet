(declare-project
  :name "janetdocs"
  :description ""
  :dependencies ["https://github.com/joy-framework/joy"]
  :author ""
  :license ""
  :url ""
  :repo "")

(declare-executable
  :name "janetdocs"
  :entry "main.janet")

(phony "server" []
  (do
    (os/shell "pkill -xf 'janet main.janet'")
    (os/shell "janet main.janet")))

(phony "watch" []
  (do
    (os/shell "pkill -xf 'janet main.janet'")
    (os/shell "janet main.janet &")
    (os/shell "fswatch -o src | xargs -n1 -I{} ./watch")))
