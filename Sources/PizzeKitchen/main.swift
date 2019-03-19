import Foundation
import Kitura
import HeliumLogger
import KituraStencil
import Application

HeliumLogger.use()

struct HelloResponse : Codable {
    let result : String //Contient Hello + prénom + nom
}

let router = Router()

// middleware = truc qui va travailler à ma place
router.all(middleware: [BodyParser(), StaticFileServer(path: "./Public")]) //Tu regardes le body, si c'est du JSON tu me renvoies du JSON, si c'est de l'XML tu me renvoies de l'XML, etc
router.add(templateEngine: StencilTemplateEngine())

router.get("/:ingredient") { request, response, next in
    let n : String
    if let ingredient = request.parameters["ingredient"] {
        n = ingredient
    } else {
        n = ""
    }
    response.send(n)
    //try response.render("Hello.stencil", context: ["ingredient": n])
    next() //j’ai fini, je passe la main
}

router.get("/") { request, response, next in
    response.send("Bonjour")
    next()
}

Kitura.addHTTPServer(onPort: 8080,  with: router)
Kitura.run()
