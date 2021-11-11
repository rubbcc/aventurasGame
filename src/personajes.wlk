import wollok.game.*
import utilidades.*
import accesorios.*
import nivel1.*

// en la implementación real, conviene tener un personaje por nivel
// los personajes probablemente tengan un comportamiendo más complejo que solamente
// imagen y posición

object personajeSimple inherits Movimiento(image = "neanthy_der.png") {
	var property energia = 0
	var property salud = 0
	var property dinero = 0
	const property inventario = []
	
	method agarrarItem(item) {
		inventario.add(item)
	}

	method tiene(item) = inventario.contains(item)
	
	method objetoInteractivoHacia() {
		return self.objetosHacia(ultimoMovimiento).find({ obj => not obj.esAtravesable() and obj.esInteractivo()})
	}
	
	method recibirAtaque(danio) {
		salud -= danio
		marcadorSalud.actualizar()
	}
	
	method cansarse(cantidad) {
		energia -= cantidad
		marcadorFuerza.actualizar()
	}
	
	method hayObjetoInteractivo() {
		return self.objetosHacia(ultimoMovimiento).any({ obj => not obj.esAtravesable() and obj.esInteractivo()})
	}
	
	override method actualizarImagen() {
		pelo.actualizar(ultimoMovimiento)
		image = ultimoMovimiento.imagenProtagonista(false)
	}
	
	override method reaccionarA(obstaculo) {}
	override method configurate() {
		super()
		game.addVisual(self)
		energia = 30
		salud = 100
		dinero = 0
		self.actualizarImagen()
		game.addVisual(pelo)
		keyboard.up().onPressDo({self.ejecutarMovimiento(direccionArriba) })
		keyboard.down().onPressDo({ self.ejecutarMovimiento(direccionAbajo) })
		keyboard.left().onPressDo({ self.ejecutarMovimiento(direccionIzquierda) })
		keyboard.right().onPressDo({ self.ejecutarMovimiento(direccionDerecha) })
		keyboard.space().onPressDo{if (self.hayObjetoInteractivo()) self.objetoInteractivoHacia().interactuarCon(self)}
	}
	
	method ejecutarMovimiento(direccion) {
		self.moverHacia(direccion)
		self.cansarse(1)
		image = direccion.imagenProtagonista(true)
	}
}

class EnemigoComun inherits Movimiento(image = "crab.png") {

	override method reaccionarA(objeto) {
		if (objeto == utilidadesParaJuego.protagonista()) objeto.recibirAtaque(5)
	}
	override method configurate() {
		super()
		game.addVisual(self)
		game.onTick(1000, "enemigoComun", {self.provocarMovimientoAleatorio()})
	}
}

class EnemigoSeguidor inherits Movimiento(image = "crab_black.png") {
	
	override method reaccionarA(objeto) {
		if (objeto == utilidadesParaJuego.protagonista()) objeto.recibirAtaque(5)
	}
	override method configurate() {
		super()
		game.addVisual(self)
		game.onTick(1000, "enemigoSeguidor", {self.moverUnPasoHacia(personajeSimple)})
	}
}
