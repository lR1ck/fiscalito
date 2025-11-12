# FISCALITO - Contexto para Claude Code

## 🎓 INFORMACIÓN CRÍTICA DEL PROYECTO

**Tipo**: Proyecto Capstone Universitario  
**Deadline**: 1 semana para MVP funcional  
**Calificación**: 100 puntos según rúbrica específica  
**Restricción**: PRESUPUESTO CERO (solo OpenAI API tiene presupuesto)

## 🎯 PROPÓSITO DEL PROYECTO

Fiscalito es una app móvil Flutter que funciona como **asistente AI para ciudadanos mexicanos** que necesitan interactuar con el SAT (autoridad fiscal mexicana).

**NO ES**: Software contable tradicional  
**ES**: Traductor/guía que elimina fricción entre el ciudadano y el SAT

### Propuesta de Valor
- Traduce terminología incomprensible del SAT a español claro
- Centraliza y automatiza procedimientos fiscales complejos
- Comunica proactivamente obligaciones fiscales
- Guía paso a paso en trámites burocráticos

## 🛠️ TECH STACK OBLIGATORIO

**RESTRICCIÓN CRÍTICA**: Todo debe ser GRATUITO excepto OpenAI

- **Frontend**: Flutter (desarrollo móvil)
- **Backend**: Firebase Cloud Functions (plan Spark - GRATIS)
- **AI/Chat**: OpenAI GPT-4o-mini (ÚNICA herramienta de pago)
- **Base de datos**: Firestore (plan gratuito)
- **Autenticación**: Firebase Auth (plan gratuito)
- **OCR**: Tesseract local o API gratuita

⚠️ **ALERTA SIEMPRE** si cualquier sugerencia requiere pago

## ✅ FEATURES CORE DEL MVP

Prioridad en este orden:

1. **Chat conversacional** con AI que explica términos del SAT
2. **Sistema de recordatorios** que indica cuándo hacer declaraciones
3. **Gestión de facturas** (CFDI) - subir/procesar
4. **OCR básico** para escanear tickets de compra
5. **Dashboard simple** mostrando estado fiscal

## 📊 RÚBRICA DE CALIFICACIÓN (100 pts)

### Distribución de Puntos
```
Funcionalidad general: 25pts  ← PRIORIDAD MÁXIMA
├─ Todas las funciones operan sin errores
├─ Cumplir TODOS los requerimientos
└─ Testing exhaustivo

Interfaz UI: 15pts  ← ALTA PRIORIDAD
├─ Diseño limpio, coherente y profesional
├─ Material Design 3
└─ Navegación intuitiva

Experiencia UX: 10pts  ← ALTA PRIORIDAD
├─ Interacción fluida
└─ Flujo de usuario natural

Arquitectura del código: 15pts  ← MEDIA-ALTA
├─ Código modular y limpio
├─ Comentarios descriptivos
└─ Buenas prácticas (naming, componentes)

Servicios externos/API: 10pts  ← MEDIA
├─ Firebase Auth funcionando
├─ Firestore operativo
└─ OpenAI integrado correctamente

Pruebas y estabilidad: 10pts  ← ALTA
├─ Sin fallos críticos
├─ Try-catch en todas las llamadas
└─ Manejo elegante de errores

Diseño/Maquetación: 10pts  ← MEDIA
├─ Layouts armónicos
├─ Responsive
└─ Buen espaciado

Innovación: 5pts  ← BONO
└─ El concepto ya es innovador
```

## 🏗️ ARQUITECTURA DEL CÓDIGO

### Estructura de Carpetas
```
lib/
├── main.dart
├── config/
│   ├── theme.dart              # Material Design 3 Dark Theme
│   └── routes.dart             # Navegación centralizada
├── models/
│   ├── user_model.dart
│   ├── cfdi_model.dart
│   └── tax_obligation_model.dart
├── services/
│   ├── openai_service.dart     # Chat AI
│   ├── firebase_auth_service.dart
│   └── firestore_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── dashboard_screen.dart
│   ├── chat/                   # FEATURE PRINCIPAL
│   │   └── chat_screen.dart
│   ├── obligations/
│   │   └── obligations_screen.dart
│   └── cfdi/
│       ├── cfdi_list_screen.dart
│       └── cfdi_upload_screen.dart
└── widgets/
    ├── custom_button.dart
    ├── tax_card.dart
    └── chat_bubble.dart
```

### Patterns a Seguir
- **State Management**: Provider (simple y gratis)
- **Arquitectura**: MVC/MVVM simple
- **Naming**: camelCase para variables, PascalCase para clases
- **Comentarios**: Sobre cada clase y métodos complejos

## 🎨 GUÍA DE DISEÑO

### Filosofía Visual
- **Inspiración**: Spotify dark theme (premium, moderno, minimalista)
- **Mood**: Profesional pero accesible, tecnológico sin intimidar
- **Principio**: Información clara en fondo oscuro, acentos vibrantes estratégicos

### Paleta de Colores

#### Base (Dark Theme)
```dart
// Backgrounds
static const Color backgroundPrimary = Color(0xFF121212);  // Negro Spotify
static const Color surfaceCard = Color(0xFF1E1E1E);        // Cards oscuras
static const Color surfaceElevated = Color(0xFF2A2A2A);    // Cards hover/activo

// Textos
static const Color textPrimary = Color(0xFFFFFFFF);        // Blanco puro
static const Color textSecondary = Color(0xFFB3B3B3);      // Gris Spotify
static const Color textDisabled = Color(0xFF535353);       // Gris muy oscuro
```

#### Acciones y Estados
```dart
// Color hero - Acciones principales (CTAs, botones importantes)
static const Color primaryMagenta = Color(0xFFFF0051);     // Rosa/Magenta vibrante

// Confirmaciones y éxito
static const Color successGreen = Color(0xFF1DB954);       // Verde Spotify

// Alertas fiscales (SAT)
static const Color warningOrange = Color(0xFFFFA726);      // Naranja alertas

// Errores críticos
static const Color errorRed = Color(0xFFEF5350);           // Rojo suave

// Información general
static const Color infoBlue = Color(0xFF42A5F5);           // Azul info
```

### Aplicación de Colores por Componente

#### Botones
- **Primary (Magenta #FF0051)**: Login, Enviar mensaje chat, Subir CFDI, Confirmar acciones
- **Success (Verde #1DB954)**: Confirmaciones secundarias, badges "Al corriente"
- **Warning (Naranja #FFA726)**: Recordatorios de fechas límite
- **Outlined**: Border con `primaryMagenta`, fondo transparente

#### Cards y Contenedores
```dart
// Card estándar
Container(
  decoration: BoxDecoration(
    color: surfaceCard,              // #1E1E1E
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  padding: EdgeInsets.all(16),
)

// Card hover/pressed
Container(
  color: surfaceElevated,            // #2A2A2A
)
```

#### Jerarquía de Texto
- **Headers (títulos pantalla)**: `textPrimary` blanco, bold, 24-28px
- **Subtitles**: `textPrimary` blanco, semibold, 18-20px
- **Body**: `textPrimary` blanco, regular, 14-16px
- **Captions/hints**: `textSecondary` gris #B3B3B3, 12-14px
- **Disabled**: `textDisabled` gris oscuro #535353

#### Bottom Navigation Bar
```dart
BottomNavigationBar(
  backgroundColor: surfaceElevated,        // #2A2A2A
  selectedItemColor: primaryMagenta,       // #FF0051
  unselectedItemColor: textSecondary,      // #B3B3B3
  type: BottomNavigationBarType.fixed,
)
```

#### Chat Interface (Feature Principal)
```dart
// Mensaje del usuario
Container(
  decoration: BoxDecoration(
    color: primaryMagenta,                 // #FF0051
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text('...', style: TextStyle(color: Colors.white)),
)

// Mensaje de la AI
Container(
  decoration: BoxDecoration(
    color: surfaceCard,                    // #1E1E1E
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text('...', style: TextStyle(color: textPrimary)),
)

// Input field
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: surfaceElevated,           // #2A2A2A
    hintStyle: TextStyle(color: textSecondary),
  ),
)
```

#### Status Badges (Dashboard)
```dart
// Estado "Al corriente" con SAT
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: successGreen.withOpacity(0.15),   // Verde transparente
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: successGreen, width: 1),
  ),
  child: Text(
    'Al corriente',
    style: TextStyle(color: successGreen, fontWeight: FontWeight.w600),
  ),
)

// Declaración pendiente
Container(
  decoration: BoxDecoration(
    color: warningOrange.withOpacity(0.15),
    border: Border.all(color: warningOrange),
  ),
  child: Text('Pendiente', style: TextStyle(color: warningOrange)),
)

// Adeudo o problema
Container(
  decoration: BoxDecoration(
    color: errorRed.withOpacity(0.15),
    border: Border.all(color: errorRed),
  ),
  child: Text('Requiere atención', style: TextStyle(color: errorRed)),
)
```

#### Progress Indicators
```dart
CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(primaryMagenta),  // #FF0051
  backgroundColor: textDisabled,                               // #535353
)

LinearProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(primaryMagenta),
  backgroundColor: surfaceElevated,
)
```

#### AppBar
```dart
AppBar(
  backgroundColor: backgroundPrimary,      // #121212 o transparente
  elevation: 0,                            // Sin sombra (flat)
  foregroundColor: textPrimary,            // Iconos/texto blanco
  centerTitle: true,
)
```

### Espaciado y Dimensiones

#### Padding Estándar
- **Pantalla completa**: 16-20px horizontal, 24px vertical
- **Cards internas**: 16px todos los lados
- **Entre elementos**: 12-16px vertical
- **Botones**: 16px horizontal, 14px vertical

#### Border Radius
- **Cards grandes**: 16px
- **Botones**: 12px
- **Chips/badges**: 20px (pill shape)
- **Input fields**: 12px
- **Chat bubbles**: 20px

#### Elevación (Shadows)
- **Cards estándar**: elevation 4
- **FAB**: elevation 6
- **Dialogs**: elevation 8
- **Bottom sheets**: elevation 16

### Iconografía
- **Paquete**: Material Icons (built-in Flutter)
- **Tamaño estándar**: 24px
- **Tamaño en botones**: 20px
- **Tamaño en bottom nav**: 24px
- **Color**: Heredar del componente padre

### Reglas de Accesibilidad (WCAG)
- ✅ Texto blanco (#FFFFFF) sobre negro (#121212): Contraste 21:1 (AAA)
- ✅ Magenta (#FF0051) sobre negro: Contraste 4.8:1 (AA)
- ✅ Verde (#1DB954) sobre negro: Contraste 4.2:1 (AA)
- ✅ Naranja (#FFA726) sobre negro: Contraste 6.1:1 (AA)
- ❌ NUNCA usar `textSecondary` (#B3B3B3) sobre `surfaceCard` (#1E1E1E)
- ❌ NUNCA usar `textDisabled` para información importante

### Referencias Visuales
- Spotify mobile app (dark theme)
- Material Design 3 dark theme guidelines
- Notion dark mode
- Discord dark theme

## 🚀 ESTRATEGIA DE DESARROLLO

### Fase 1: Frontend Mock (Días 1-2) ← ESTADO ACTUAL
- ✅ Theme dark configurado
- ⏳ Splash screen
- ⏳ Login/Register con UI completa
- ⏳ Dashboard con cards mock
- ⏳ Chat interface básica
- ⏳ Navegación entre pantallas

**Objetivo**: UI completa funcional con datos falsos = 25pts UI/UX asegurados

### Fase 2: Integración OpenAI (Días 3-4)
- ⏳ Servicio OpenAI configurado
- ⏳ Chat funcional con respuestas reales
- ⏳ Prompt engineering para explicar términos SAT
- ⏳ Loading states y manejo de errores

**Objetivo**: Feature principal funcionando = 25pts funcionalidad

### Fase 3: Firebase (Días 5-6)
- ⏳ Firebase Auth (email/password)
- ⏳ Firestore para persistir datos
- ⏳ CRUD de facturas (CFDI)
- ⏳ Sistema de recordatorios básico

**Objetivo**: Servicios externos integrados = 10pts API

### Fase 4: Features + Polish (Día 7)
- ⏳ OCR básico (Tesseract o API gratuita)
- ⏳ Testing exhaustivo de flujos
- ⏳ Documentación completa del código
- ⏳ Manejo de errores elegante en toda la app
- ⏳ Performance optimization

**Objetivo**: Estabilidad + Innovación = 15pts finales

## 📝 REGLAS DE CÓDIGO

### SIEMPRE:
- ✅ **Comentar clases y métodos**: Docstrings en formato `///`
- ✅ **Try-catch en TODAS las llamadas async**: Nunca dejar sin manejo
- ✅ **Validación de inputs**: Regex para emails, longitud de contraseñas
- ✅ **Loading states**: CircularProgressIndicator durante operaciones
- ✅ **Error messages amigables**: Traducir errores técnicos a lenguaje claro
- ✅ **Null safety**: Usar `?`, `!`, `??` correctamente
- ✅ **Const constructors**: Para widgets que no cambian
- ✅ **Keys en listas**: UniqueKey() o ValueKey() en ListView

### NUNCA:
- ❌ **Hardcodear API keys**: Usar flutter_dotenv o --dart-define
- ❌ **Dejar TODOs sin resolver**: Completar o eliminar antes de entregar
- ❌ **Prints en producción**: Usar logger package o eliminar
- ❌ **Código comentado**: Eliminarlo (usa git para historial)
- ❌ **Magic numbers**: Definir constantes con nombres descriptivos
- ❌ **Widgets gigantes**: Extraer a widgets separados si >100 líneas
- ❌ **setState en dispose**: Verificar mounted antes de setState

### Nomenclatura
```dart
// ✅ BIEN
class DashboardScreen extends StatelessWidget {}
final String userName = 'Juan';
void _handleLogin() {}
const double kDefaultPadding = 16.0;

// ❌ MAL
class dashboard extends StatelessWidget {}
final String UserName = 'Juan';
void HandleLogin() {}
const double padding = 16.0;
```

### Estructura de Archivos
```dart
/// Pantalla principal del dashboard fiscal
/// 
/// Muestra:
/// - Resumen del estado fiscal del usuario
/// - Próximas obligaciones
/// - Acceso rápido a features principales
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variables de estado
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  /// Carga los datos del usuario desde Firestore
  Future<void> _loadData() async {
    try {
      // Lógica de carga
      setState(() => _isLoading = false);
    } catch (e) {
      // Manejo de error
      _showErrorSnackbar('Error al cargar datos: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      // UI aquí
    );
  }
}
```

## 🔍 CONTEXTO MEXICANO - SAT

### Términos Clave a Manejar
- **SAT**: Servicio de Administración Tributaria (IRS mexicano)
- **CFDI**: Comprobante Fiscal Digital por Internet (factura electrónica XML)
- **RFC**: Registro Federal de Contribuyentes (Tax ID, 13 caracteres)
- **Declaración**: Reporte mensual/anual de ingresos e impuestos
- **Régimen Fiscal**: Categoría de contribuyente (RESICO, General, etc.)
- **RESICO**: Régimen Simplificado de Confianza (nuevo desde 2022, más simple)
- **ISR**: Impuesto Sobre la Renta
- **IVA**: Impuesto al Valor Agregado (16%)
- **Constancia de Situación Fiscal**: Documento que certifica datos fiscales

### Features Específicas SAT

#### Calendario Fiscal
- **Día 17**: Declaración mensual (puede variar según 6to dígito de RFC)
- **Marzo/Abril**: Declaración anual (personas físicas)
- **Cada 2 meses**: Declaración bimestral (algunos regímenes)

#### Estructura CFDI (XML)
```xml
<cfdi:Comprobante>
  <cfdi:UUID>12345678-1234-1234-1234-123456789012</cfdi:UUID>
  <cfdi:Emisor Rfc="ABC123456789" Nombre="Empresa SA"/>
  <cfdi:Receptor Rfc="XYZ987654321" Nombre="Juan Pérez"/>
  <cfdi:Total>1000.00</cfdi:Total>
  <cfdi:Fecha>2025-01-15T10:30:00</cfdi:Fecha>
</cfdi:Comprobante>
```

#### OCR Requirements
Extraer de tickets/facturas:
- RFC emisor (13 caracteres)
- RFC receptor (13 caracteres)
- Monto total (formato $X,XXX.XX)
- Fecha (DD/MM/AAAA)
- Folio fiscal (UUID si es CFDI)

### Prompts para OpenAI (Ejemplos)

#### System Prompt Base
```
Eres Fiscalito, un asistente fiscal especializado en ayudar a ciudadanos 
mexicanos con el SAT. Tu trabajo es:
1. Traducir terminología fiscal compleja a español claro y cotidiano
2. Explicar procedimientos del SAT paso a paso
3. Ser empático y paciente (muchos usuarios se sienten intimidados)
4. NUNCA dar asesoría legal o contable profesional (recomendar experto si es complejo)
5. Usar ejemplos concretos cuando sea posible

Tono: Amigable, profesional, educativo. Evita jerga innecesaria.
```

#### Ejemplo de Interacción
```
Usuario: "¿Qué es el RESICO?"
Fiscalito: "El RESICO (Régimen Simplificado de Confianza) es como la 'opción 
fácil' para declarar impuestos que el SAT creó en 2022. 

Imagínalo así: antes tenías que hacer cálculos complicados cada mes. Con RESICO, 
el SAT te cobra una tasa fija (1% a 2.5%) sobre tus ingresos. Es como un plan 
'todo incluido' más simple.

¿Es para ti? Si ganas menos de $3.5 millones al año, probablemente sí. 

¿Quieres que te explique cómo cambiarte a RESICO?"
```

## 🎯 PRIORIZACIÓN

### Matriz de Decisión
Al implementar features, pregúntate:
1. **¿Da puntos directos en rúbrica?** → Alta prioridad
2. **¿Es visible en demo de 3 minutos?** → Media-alta prioridad
3. **¿Requiere backend complejo?** → Posponer o simplificar
4. **¿Puede fallar fácilmente?** → Agregar más validaciones

### Orden de Implementación Features
```
Prioridad 1 (Crítico - 50pts):
├─ UI completa de todas las pantallas (mock data OK)
├─ Navegación fluida entre pantallas
├─ Chat con OpenAI funcionando
└─ Dashboard mostrando datos (aunque sean fake)

Prioridad 2 (Importante - 30pts):
├─ Firebase Auth (login/register)
├─ Firestore guardando datos
├─ Sistema de recordatorios básico
└─ CRUD de facturas

Prioridad 3 (Nice to have - 20pts):
├─ OCR para escanear tickets
├─ Notificaciones push
├─ Exportar reportes
└─ Dark/Light theme toggle
```

### Regla 80/20
- **80% del tiempo**: Features que dan puntos directos
- **20% del tiempo**: Polish, testing, documentación

### Red Flags (Evitar)
- ❌ Pasar >2 horas en un solo componente visual
- ❌ Intentar features complejas sin tener lo básico
- ❌ Sobre-ingenierizar (KISS principle)
- ❌ No probar en dispositivo real hasta el final

## 📚 RECURSOS ÚTILES

### Documentación Oficial
- Flutter: https://docs.flutter.dev/
- Firebase Flutter: https://firebase.google.com/docs/flutter/setup
- Material Design 3: https://m3.material.io/
- OpenAI API: https://platform.openai.com/docs/api-reference

### Packages Recomendados (GRATIS)
```yaml
dependencies:
  # State management
  provider: ^6.1.1
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  
  # HTTP y APIs
  http: ^1.1.2
  dio: ^5.4.0  # Alternativa más robusta
  
  # UI Components
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  
  # Utilidades
  intl: ^0.19.0  # Formateo de fechas/números
  flutter_dotenv: ^5.1.0  # Variables de entorno
  
  # OCR (evaluar cuál funciona mejor)
  google_mlkit_text_recognition: ^0.11.0  # GRATIS
  # O tesseract_ocr: ^0.4.24
```

### Repos de Referencia
- Flutter AI Toolkit: https://github.com/flutter/ai
- Flutter Auth UI: https://github.com/firebase/flutterfire
- Flutter Chat UI: https://pub.dev/packages/flutter_chat_ui

### SAT (México)
- Portal oficial: https://www.sat.gob.mx
- CFDI samples: Buscar "ejemplos CFDI XML SAT"
- Calendario fiscal: https://www.sat.gob.mx/aplicacion/42150/calendario-de-obligaciones

## ⚠️ ALERTAS IMPORTANTES

### Durante Desarrollo
1. **No sobre-ingenierizar**: MVP funcional > App perfecta incompleta
2. **Testing continuo**: Probar cada feature inmediatamente después de implementar
3. **Commits frecuentes**: Git commit después de cada pantalla/feature completado
4. **Hot reload es tu amigo**: Usa `r` constantemente, `R` para full restart
5. **Presupuesto cero**: Alertar SIEMPRE sobre cualquier costo oculto

### Antes de Entregar
- [ ] Todas las pantallas funcionan sin crashes
- [ ] No hay prints de debug en consola
- [ ] Todos los TODOs resueltos o eliminados
- [ ] README.md actualizado con screenshots
- [ ] Código comentado (especialmente lógica compleja)
- [ ] APK generado y probado en dispositivo real
- [ ] Video demo grabado (2-3 minutos)

### Si Algo Sale Mal
1. **No entres en pánico**: Prioriza lo que SÍ funciona
2. **Documenta el issue**: Comenta en código por qué algo no funciona
3. **Fallback a mock data**: Si Firebase falla, usa datos locales
4. **Comunica transparente**: Explica en README qué quedó pendiente y por qué

## 🎓 ENTREGABLES FINALES

### Archivos Requeridos
- [ ] **APK funcional** (debug o release)
- [ ] **Código fuente** en GitHub (repo público o privado según requisitos)
- [ ] **README.md** con:
  - Screenshots de cada pantalla
  - Instrucciones de instalación
  - Listado de features implementadas
  - Tech stack usado
  - Créditos y recursos
- [ ] **Video demo** (2-3 minutos máximo):
  - Mostrar cada feature principal
  - Explicar propuesta de valor
  - Demostrar chat con AI
  - Navegar entre pantallas
- [ ] **Documentación técnica** (puede ser en README o archivo separado):
  - Arquitectura del código
  - Decisiones técnicas importantes
  - Próximos pasos / roadmap

### Formato de Presentación
- Diseño claro y profesional
- Sin errores de ortografía
- Screenshots en alta calidad
- Links funcionales
- Sección de "troubleshooting" si aplica

---

## 📍 ESTADO ACTUAL DEL PROYECTO

**Última actualización**: [Fecha]

**Completado**:
- ✅ Estructura de carpetas definida
- ✅ Paleta de colores (dark theme Spotify-inspired)
- ✅ CLAUDE.md con contexto completo

**En progreso**:
- ⏳ Configuración inicial de Flutter
- ⏳ Theme implementation en código

**Pendiente**:
- ⏳ Splash screen
- ⏳ Login/Register screens
- ⏳ Dashboard
- ⏳ Chat interface
- ⏳ Integración OpenAI
- ⏳ Firebase setup
- ⏳ OCR implementation

**Siguiente paso**: Implementar theme.dart con la paleta dark definida

---

## 💬 COMANDOS ÚTILES PARA CLAUDE CODE

```bash
# Crear nueva pantalla
"Crea la pantalla de [nombre] siguiendo la arquitectura en CLAUDE.md"

# Revisar código
"Revisa [archivo] y sugiere mejoras según las reglas de código en CLAUDE.md"

# Debug
"Tengo este error: [error]. Ayúdame a resolverlo sin romper la arquitectura"

# Refactor
"Refactoriza [componente] para mejorar puntuación en la rúbrica"

# Testing
"Ayúdame a crear casos de prueba para [feature]"
```

---

**Recuerda**: La meta es un MVP funcional que demuestre todas las features core. 
Prioriza estabilidad sobre complejidad. ¡Tú puedes! 🚀
