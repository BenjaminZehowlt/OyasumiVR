use crate::MAIN_HTTP_SERVER_PORT;

#[tauri::command]
pub fn get_http_server_port() -> Option<u16> {
    let port_guard = MAIN_HTTP_SERVER_PORT.lock().unwrap();
    match port_guard.as_ref() {
        Some(port) => Some(*port),
        None => None,
    }
}
