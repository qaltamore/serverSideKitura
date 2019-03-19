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

/*var pizzeList = [{
    name: "Calzone",
    ingredients: [
        "oeuf",
        "jambon",
        "mozarella",
        "sauce tomate"
    ]
    }]*/
struct Pizza: Codable {
    var name: String
    var ingredients: [String]
}

var listCalzoneIngredients = ["oeuf", "jambon", "mozarella", "sauce tomate"]
var listQuatreFromagesIngredients = ["gorgonzola", "mozarella", "chèvre", "parmesan", "sauce tomate"]
let pizzeList = [
    Pizza(name: "Calzone", ingredients: listCalzoneIngredients),
    Pizza(name: "4 Frômages", ingredients: listQuatreFromagesIngredients)
]


// middleware = truc qui va travailler à ma place
router.all(middleware: [BodyParser(), StaticFileServer(path: "./Public")]) //Tu regardes le body, si c'est du JSON tu me renvoies du JSON, si c'est de l'XML tu me renvoies de l'XML, etc
router.add(templateEngine: StencilTemplateEngine())

/* on  garde en exemple pour le moment
 
 if let ingredient = request.parameters["ingredient"]
 
 
 router.post("/api/hello") { request, response, next in
    print(request.body ?? "Body is nil")
    //il n'y a potentiellement pas de body dans une request
    if let body = request.body?.asJSON {
        print("Oui")
        if let p = body["prenom"], let n = body["nom"] {
            print("Test")
            response.send(HelloResponse(result: "Hello \(p) \(n)"))
        }
    } else {
        response.status(.notFound)
    }
    
    next()
}*/

router.get("/") { request, response, next in
    try response.render("Home.stencil", context: ["pizzeList": pizzeList])
    next()
}

router.get("/newRecipe") { request, response, next in
    let n : String
    if let ingredient = request.parameters["ingredient"] {
        n = ingredient
    } else {
        n = ""
    }
    try response.render("NewRecipe.stencil")
    next()
}

Kitura.addHTTPServer(onPort: 8080,  with: router)
Kitura.run()
