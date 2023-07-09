use log::error;
use serde::Serialize;
use std::time::{SystemTime, UNIX_EPOCH};
use sysinfo::{ProcessExt, Signal, System, SystemExt};
use tauri::Manager;
use tokio::sync::Mutex;

use crate::globals::{TAURI_APP_HANDLE, TAURI_CLI_MATCHES};

lazy_static! {
    static ref SYSINFO: Mutex<System> = Mutex::new(System::new_all());
}

pub mod sidecar_manager;

pub async fn is_process_active(process_name: &str) -> bool {
    let mut sysinfo_guard = SYSINFO.lock().await;
    let sysinfo = &mut *sysinfo_guard;
    sysinfo.refresh_processes();
    let processes = sysinfo.processes_by_exact_name(process_name);
    processes.count() > 0
}

pub async fn stop_process(process_name: &str, kill: bool) {
    let mut sysinfo_guard = SYSINFO.lock().await;
    let sysinfo = &mut *sysinfo_guard;
    sysinfo.refresh_processes();
    let processes = sysinfo.processes_by_exact_name(process_name);
    for process in processes {
        if kill {
            let _ = process.kill_with(Signal::Kill);
        } else if process.kill_with(Signal::Term).is_none() {
            if process.kill_with(Signal::Quit).is_none() {
                let _ = process.kill_with(Signal::Kill);
            }
        }
    }
}

pub fn get_time() -> u128 {
    let now = SystemTime::now();
    let since_the_epoch = now.duration_since(UNIX_EPOCH).expect("Time went backwards");
    since_the_epoch.as_millis()
}

pub async fn send_event<S: Serialize + Clone>(event: &str, payload: S) {
    let app_handle_guard = TAURI_APP_HANDLE.lock().await;
    let app_handle = app_handle_guard.as_ref().unwrap();
    match app_handle.emit_all(event, payload) {
        Ok(_) => {}
        Err(e) => {
            error!("[Core] Failed to send event {}: {}", event, e);
        }
    };
}

pub async fn cli_sidecar_overlay_mode() -> String {
    let default = "release";
    let match_guard = TAURI_CLI_MATCHES.lock().await;
    let mode = match match_guard
        .as_ref()
        .unwrap()
        .args
        .get("overlay-sidecar-mode")
    {
        Some(data) => data.value.as_str().unwrap_or(default),
        None => default,
    };
    mode.to_string()
}

pub async fn cli_grpc_port_core() -> u32 {
    let default: u32 = 0;
    let match_guard = TAURI_CLI_MATCHES.lock().await;
    let arg = match_guard.as_ref().unwrap().args.get("grpc-port-core");
    let port = match arg {
        Some(args) => match args
            .value
            .as_str()
            .unwrap_or(&default.to_string().as_str())
            .parse::<u32>()
        {
            Ok(port) => port,
            Err(_) => default,
        },
        None => default,
    };
    port
}
