  # 📝 mi_notes

Aplicación Flutter desarrollada para gestionar **notas y recordatorios personales**, integrada con **Firebase** y **notificaciones locales programadas**.  
Permite crear notas, configurar recordatorios con hora específica y recibir notificaciones en Android, incluso cuando la aplicación está cerrada.


## 🚀 Características principales

- ✅ **Integración con Firebase**  
  Usa `firebase_core` y `firebase_messaging` para manejar servicios de autenticación, almacenamiento y mensajería en la nube.

- ✅ **Notificaciones locales programadas**  
  Configuradas con `flutter_local_notifications`, permiten enviar:
  - Notificaciones instantáneas.  
  - Recordatorios programados a fecha y hora definidas.  
  - Alarmas que se mantienen activas tras reiniciar el dispositivo.

- ✅ **Compatibilidad con Android 13+**  
  Se incluyen permisos modernos como `POST_NOTIFICATIONS` y `SCHEDULE_EXACT_ALARM`.

- ✅ **Sistema de recordatorios**  
  Los recordatorios se notifican en segundo plano con título y descripción personalizados.

