(import dotenv)
(dotenv/load)

(import joy :prefix "")
(import ./helpers :prefix "")


(defroutes routes
  [:get "/" :home/index]
  [:delete "/sessions" :sessions/destroy]
  [:get "/github-auth" :home/github-auth]
  [:post "/searches" :home/searches]
  [:get "/bindings/:binding-id/examples/form" :examples/form]
  [:get "/bindings/:binding-id/examples/new" :examples/new]
  [:post "/bindings/:binding-id/examples" :examples/create]
  [:get "/examples/:id/edit" :examples/edit]
  [:patch "/examples/:id" :examples/patch]
  [:delete "/examples/:id" :examples/destroy]
  [:get "/*" :bindings/show])


(def app (app {:routes routes
               :layout layout
               :404 /404}))


(defn main [& args]
  (def port (get args 1 "9001"))

  (db/connect)
  (server app port) # stops listening on SIGINT
  (db/disconnect))
