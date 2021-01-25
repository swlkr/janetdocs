(import joy :prefix "")
(import ./helpers :prefix "")


(defroutes routes
  [:get "/" :home/index]
  [:delete "/sessions" :sessions/destroy]
  [:get "/github-auth" :home/github-auth]
  [:post "/searches" :home/searches]
  [:get "/bindings/random" :examples/random]
  [:get "/bindings/:binding-id/examples/form" :examples/form]
  [:get "/bindings/:binding-id/examples/new" :examples/new]
  [:post "/bindings/:binding-id/examples" :examples/create]
  [:get "/examples/:id/edit" :examples/edit]
  [:patch "/examples/:id" :examples/patch]
  [:delete "/examples/:id" :examples/destroy]
  [:get "/export.json" :examples/export]
  [:get "/playground/example/:id" :playground/example]
  [:get "/playground" :playground/home]
  [:get "/*" :bindings/show])


(def app (app {:routes routes
               :layout layout
               :404 /404}))


(defn main [& args]
  (db/connect (env :database-url))
  (server app (env :port))
  (db/disconnect))
