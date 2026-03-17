const API_BASE_URL = '/api/camera'

async function parseResponse(response) {
  const contentType = response.headers.get('content-type') || ''

  if (contentType.includes('application/json')) {
    return response.json()
  }

  return response.text()
}

async function handleResponse(response) {
  const data = await parseResponse(response)

  if (!response.ok) {
    const message =
      typeof data === 'string'
        ? data
        : data?.message || data?.error || 'Request failed.'

    throw new Error(message)
  }

  return data
}

export async function updateSettings(payload) {
  const response = await fetch(`${API_BASE_URL}/update_settings`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  })

  return handleResponse(response)
}

export async function getCameraStatus() {
  const response = await fetch(`${API_BASE_URL}/camera_status`)
  return handleResponse(response)
}

export async function resetCamera() {
  const response = await fetch(`${API_BASE_URL}/reset`, {
    method: 'POST',
  })

  return handleResponse(response)
}

export async function applyPreset(preset) {
  const response = await fetch(`${API_BASE_URL}/apply_preset`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ preset }),
  })

  return handleResponse(response)
}

export function buildCustomPhotoUrl(width, height) {
  const params = new URLSearchParams({
    w: String(width),
    h: String(height),
  })

  return `${API_BASE_URL}/take_photo_custom?${params.toString()}`
}