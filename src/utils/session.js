export function getSession() {
  try {
    const raw = localStorage.getItem("nabotingSession")
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export function getUserId() {
  return getSession()?.userId ?? null
}
