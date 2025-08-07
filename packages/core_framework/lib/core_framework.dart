library core_framework;

// ===== CONFIG =====
export 'src/config/app_config.dart';
// ===== CORE ABSTRACTIONS =====
export 'src/core/app_boot_result.dart';
export 'src/core/app_initializer.dart';
export 'src/core/error_handler.dart';
// ===== DEPENDENCY INJECTION =====
export 'src/di/dependency_registrar.dart';
export 'src/di/di_container.dart';
export 'src/di/di_context_accessor.dart';
export 'src/di/injection_module.dart';
export 'src/di/scoped_dependency_registrar.dart';
export 'src/di/scoped_service_locator.dart';
export 'src/di/service_locator.dart';
// ===== FEATURE SYSTEM =====
export 'src/feature/base_feature.dart';
export 'src/feature/events.dart';
export 'src/feature/feature.dart';
export 'src/feature/feature_context.dart';
export 'src/feature/feature_registry.dart';
export 'src/feature/shell_feature.dart';
// ===== HTTP =====
export 'src/http/exceptions/http_exceptions.dart';
export 'src/http/http_client.dart';
export 'src/http/models/http_request.dart';
export 'src/http/models/http_request_config.dart';
export 'src/http/models/http_response.dart';
export 'src/http/models/multipart_file.dart';
// ===== LOGGING =====
export 'src/logging/logging.dart';
// ===== MESSAGING =====
export 'src/messaging/event_bus.dart';
// ===== PLATFORM =====
export 'src/platform/app_info_service.dart';
// ===== ROUTING =====
export 'src/routing/app_router.dart';
export 'src/routing/global_route_guard_service.dart';
export 'src/routing/guard_registry.dart';
export 'src/routing/navigation/redirect_service.dart';
export 'src/routing/route_cache.dart';
export 'src/routing/route_guard.dart';
export 'src/routing/route_guard_service.dart';
export 'src/routing/route_module.dart';
export 'src/routing/shell_route_module.dart';
// ===== STORAGE =====
export 'src/storage/exceptions/storage_exception.dart';
export 'src/storage/storage_client.dart';
