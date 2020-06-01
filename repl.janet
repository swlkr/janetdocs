(use joy)

(import dotenv)
(dotenv/load)

(db/connect (env :database-url))

(repl nil
      (fn [_ y] (printf "%Q" y))
      (fiber/getenv (fiber/current)))

(db/disconnect)
