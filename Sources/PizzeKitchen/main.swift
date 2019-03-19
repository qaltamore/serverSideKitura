import Kitura
import HeliumLogger
import KituraStencil

HeliumLogger.use()

let router = Router()

struct Pizza: Codable {
    var name: String
    var ingredients: [String]
}

struct Order: Codable {
    var numero: Int
    var name: String
}

var listCalzoneIngredients = ["oeuf", "jambon", "mozarella", "sauce tomate"]
var listQuatreFromagesIngredients = ["gorgonzola", "mozarella", "chèvre", "parmesan", "sauce tomate"]
var pizzeList = [
    Pizza(name: "Calzone", ingredients: listCalzoneIngredients),
    Pizza(name: "4 Frômages", ingredients: listQuatreFromagesIngredients)
]

var orders = [Order]()
orders = [
    Order(numero: 0, name: "Calzone"),
    Order(numero: 1, name: "4 Frômages"),
    Order(numero: 2, name: "Regina"),
    Order(numero: 3, name: "Calzone")
]


// middleware = truc qui va travailler à ma place
router.all(middleware: [BodyParser(), StaticFileServer(path: "./Public")]) //Tu regardes le body, si c'est du JSON tu me renvoies du JSON, si c'est de l'XML tu me renvoies de l'XML, etc
router.add(templateEngine: StencilTemplateEngine())

/* on  garde en exemple pour le moment
 
 if let ingredient = request.parameters["ingredient"]
 
}*/

router.get("/") { request, response, next in
    try response.render("Home.stencil", context: ["pizzeList": pizzeList])
    next()
}

router.get("/newRecipe") { request, response, next in
    let tiens = ""
    try response.render("NewRecipe.stencil", context: ["useless": tiens])
    next()
}

router.post("/newRecipe") { request, response, next in
    print(request.body ?? "Body is nil")
    
    if let body = request.body?.asURLEncoded {
        if let nameRecipe = body["nameRecipe"], let ingredientsRecipe = body["ingredientsRecipe"] {
            let ingredientsRecipeTab = ingredientsRecipe.components(separatedBy: ",")
            var ingredientsRecipeTabTrimmed: [String] = []
            
            for item in ingredientsRecipeTab {
                ingredientsRecipeTabTrimmed.append(item.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            let pizza = Pizza(name: nameRecipe, ingredients: ingredientsRecipeTabTrimmed)
            pizzeList.append(pizza)
            
            try response.render("Home.stencil", context: ["pizzeList": pizzeList])
        }
    } else {
        response.status(.notFound)
    }
    
    next()
}

router.get("/orders") { request, response, next in
    try response.render("Orders.stencil", context: ["orders": orders])
    next()
}

router.post("/orders") { request, response, next in
    
    print(request.body ?? "Body is nil")
    
    if let body = request.body?.asURLEncoded {
        if let deliveredPizze = body["pizze"] {
            print("deliveredPizze: ", deliveredPizze)
            let deliveredPizzeTab = deliveredPizze.components(separatedBy: ",")
            
            for pizza in deliveredPizzeTab {
                var pizzaIndex: Int! = Int(pizza)
                orders.remove(at: pizzaIndex)
            }
            
            var tmpTab = orders
            for (index, order) in orders.enumerated() {
                tmpTab[index].numero = index
            }
            orders = tmpTab
        }
    }
    
    try response.render("Orders.stencil", context: ["orders": orders])
    
    next()
}

Kitura.addHTTPServer(onPort: 8080,  with: router)
Kitura.run()

/*extension Array {
    mutating func remove(_ element: Element) {
        self = self.filter { $0 != element }
    }
}*/
