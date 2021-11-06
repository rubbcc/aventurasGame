import wollok.game.*
import personajes.*
import nivel1.*

object utilidadesParaJuego {
	var property nivel = 1
	method posicionArbitraria() {
		return game.at(
			0.randomUpTo(game.width()).truncate(0), 0.randomUpTo(game.height() - 1).truncate(0)
		)
	}
	method posicionArbitrariaNoOcupada() {
		var posicionA = self.posicionArbitraria()
		if (game.getObjectsIn(posicionA).size() > 1)
			posicionA = self.posicionArbitrariaNoOcupada()
		return posicionA
	}
	method protagonista() = personajeSimple
}

object direccionArriba{}
object direccionAbajo{}
object direccionIzquierda{}
object direccionDerecha{}

object marcador {
    method position() = game.at(1,game.height() - 1)
    method text() {
    	var mensaje = ""
    	mensaje = "Energia: " + personajeSimple.energia() + " - " 
        mensaje += "Salud: " + personajeSimple.salud() + " - "
        mensaje += "Dinero: " + personajeSimple.dinero() + " - "
        mensaje += "Inventario: " + personajeSimple.inventario().size()
        return mensaje
    }
}

object marcadorPerder {
    method position() = game.at(1,game.height() - 1)
    method text() = "Perdiste el nivel"}

class Movimiento {
	var property position = game.at(0,0)
	var property ultimoMovimiento = direccionAbajo

	method reaccionarA(obstaculo)
		
	method esAtravesable() = false
	
	method esInteractivo() = false	
	
	method configurate() { position = utilidadesParaJuego.posicionArbitrariaNoOcupada() }
	
	method siguienteMovimientoHacia(direccion) {
		var siguiente
		if (direccion == direccionDerecha) 
			siguiente =
				if (position.x() == game.width() - 1)
					game.at(0, position.y())
				else
					position.right(1)
		if (direccion == direccionIzquierda) 
			siguiente =
				if (position.x() == 0)
					game.at(game.width() - 1, position.y())
				else
					position.left(1) 
		if (direccion == direccionArriba) 
			siguiente =
				if (position.y() == game.height() - 2)
					game.at(position.x(), 0)
				else
					position.up(1)
		if (direccion == direccionAbajo) 
			siguiente =
				if (position.y() == 0)
					game.at(position.x(), game.height() - 2)
				else
					position.down(1)
		return siguiente
	}

	method objetosHacia(direccion) {
		return game.getObjectsIn(self.siguienteMovimientoHacia(direccion))
	}
	
	method puedeMover(direccion) {
		return self.objetosHacia(direccion).all{ objeto => objeto.esAtravesable() }
	} 

	method moverHacia(direccion) {
		if (not nivelBloques.juegoEnPausa()) {
			ultimoMovimiento = direccion
			if (self.puedeMover(direccion)) position = self.siguienteMovimientoHacia(direccion)
			else {
				const objetoHacia = self.objetosHacia(direccion).find{objeto => not objeto.esAtravesable()}
				objetoHacia.reaccionarA(self)
				self.reaccionarA(objetoHacia)
			}
		}
	}
	
	method provocarMovimientoAleatorio() {
		const movimientosPosibles = [direccionArriba, direccionAbajo, direccionDerecha, direccionIzquierda]
		self.moverHacia(movimientosPosibles.anyOne())
	}
	
	method moverUnPasoHacia(objetivo) {
		const xObjetivo = objetivo.position().x()
		const yObjetivo = objetivo.position().y()
		const numAleatorio = 0.randomUpTo(100)
		if (numAleatorio < 50){
			if(xObjetivo != position.x()) {
				if (xObjetivo < position.x()) self.moverHacia(direccionIzquierda)
				else self.moverHacia(direccionDerecha)
			}
			else {
				if (yObjetivo < position.y()) self.moverHacia(direccionAbajo)
				else self.moverHacia(direccionArriba)
			}
		}
		else {
			if(yObjetivo != position.y()) {
				if (yObjetivo < position.y()) self.moverHacia(direccionAbajo)
				else self.moverHacia(direccionArriba)
			}
			else {
				if (xObjetivo < position.x()) self.moverHacia(direccionIzquierda)
				else self.moverHacia(direccionDerecha)
			}
		}
	}
}

class Animacion {
	var imagenes
	var duracion
	var cuadro = 0
	var detener = false
	var repetirInfinito = false
	var repetirVeces = 0
	
	method repetir() { repetirInfinito = true }
	method repetir(veces) { if (repetirVeces > 0) repetirVeces = veces }
	
	method detener() { detener = true }
	
	method animar(objeto) {
		if (detener) detener = false
		else {
			const cantImagenes = imagenes.size()
			cuadro += 1
			if (cuadro == cantImagenes) {
				cuadro = 0
				if (repetirInfinito or repetirVeces > 0) {
					game.schedule(duracion.div(cantImagenes), {self.animar(objeto)})
					if (repetirVeces > 0) repetirVeces -= 1
				}
			}
			else game.schedule(duracion.div(cantImagenes), {self.animar(objeto)})
			objeto.image(imagenes.get(cuadro))
		}
	}
}

object sumaRecursiva {
	method irA0(numero) {
		var nuevoNum = numero
		if (numero > 0) {
			nuevoNum = self.irA0(numero - 1)
		}
		return nuevoNum
	}
}