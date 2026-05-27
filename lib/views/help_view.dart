import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // 👈 IMPORTANTE: Añadimos el paquete

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // Método que ejecuta la acción de abrir la URL
  Future<void> _launchGitHub(BuildContext context) async {
    // Aquí he puesto la URL de tu repo según el nombre de tus archivos. ¡Cámbiala si es otra!
    final Uri url = Uri.parse(
      'https://github.com/anabgar3105/foodmatch_app/issues',
    );

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('No se pudo abrir $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace. Revisa tu conexión.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Soporte'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),

            // CABECERA VISUAL
            Icon(
              Icons.support_agent,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              '¿En qué podemos ayudarte?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Si tienes problemas con la aplicación o quieres darnos sugerencias, estamos aquí para escucharte.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // BOTÓN DE GITHUB FUNCIONAL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.code),
                  label: const Text(
                    'Abrir Issue en GitHub',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _launchGitHub(context),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // PREGUNTAS FRECUENTES (FAQs) EN TARJETAS
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Preguntas Frecuentes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildFAQ(
              '¿Cómo puedo añadir una receta nueva?',
              'Ve a la pestaña "+" en el menú inferior. Allí podrás subir una foto, escribir los ingredientes y explicar los pasos de tu receta. ¡Asegúrate de darle a guardar!',
            ),
            _buildFAQ(
              '¿Cómo funciona la pestaña de Swipe?',
              '¡Es muy fácil! Desliza la tarjeta hacia la derecha si la receta te gusta y quieres guardarla en tus favoritos, o desliza hacia la izquierda si prefieres pasar a la siguiente.',
            ),
            _buildFAQ(
              '¿Puedo editar los datos de mi perfil?',
              'En esta versión MVP, los datos de perfil son fijos tras el registro. ¡Pero estamos trabajando duro para añadir la edición de perfil en la próxima actualización!',
            ),
            _buildFAQ(
              'He encontrado un error, ¿qué hago?',
              '¡Gracias por avisar! Puedes usar el botón de arriba para ir a nuestro repositorio en GitHub y abrir una "Issue" detallando el problema. Así podremos arreglarlo lo antes posible.',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Tarjetas para FAQ
  Widget _buildFAQ(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            iconColor: const Color(0xFFFF7A59),
            collapsedIconColor: Colors.grey,
            title: Text(
              question,
              style:  TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFFFF7A59) ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  answer,
                  style: TextStyle(color: Colors.grey[600], height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
