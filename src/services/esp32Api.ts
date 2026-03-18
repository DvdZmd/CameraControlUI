export type MoveDirection = 'left' | 'right' | 'up' | 'down'
export type MoveAction = 'start' | 'stop'

export interface Esp32StatusResponse {
  ok?: boolean
  connected?: boolean
  device_name?: string
  device_address?: string
  error?: string
  [key: string]: unknown
}

export interface ApiResponse {
  ok: boolean
  error?: string
  [key: string]: unknown
}

async function parseJsonSafe(response: Response) {
  try {
    return await response.json()
  } catch {
    return {}
  }
}

async function request<T>(url: string, options?: RequestInit): Promise<T> {
  const response = await fetch(url, {
    headers: {
      'Content-Type': 'application/json',
    },
    ...options,
  })

  const data = await parseJsonSafe(response)

  if (!response.ok) {
    const message =
      typeof data?.error === 'string'
        ? data.error
        : `Request failed with status ${response.status}`

    throw new Error(message)
  }

  return data as T
}

export async function getEsp32Status(): Promise<Esp32StatusResponse> {
  return request<Esp32StatusResponse>('/api/esp32/status', {
    method: 'GET',
  })
}

export async function connectEsp32(): Promise<ApiResponse> {
  return request<ApiResponse>('/api/esp32/connect', {
    method: 'POST',
  })
}

export async function disconnectEsp32(): Promise<ApiResponse> {
  return request<ApiResponse>('/api/esp32/disconnect', {
    method: 'POST',
  })
}

export async function moveEsp32(direction: MoveDirection): Promise<ApiResponse> {
  return request<ApiResponse>('/api/esp32/move', {
    method: 'POST',
    body: JSON.stringify({
      direction,
      action: 'start',
    }),
  })
}

export async function stopEsp32(): Promise<ApiResponse> {
  return request<ApiResponse>('/api/esp32/move', {
    method: 'POST',
    body: JSON.stringify({
      action: 'stop',
    }),
  })
}

export async function centerEsp32(): Promise<ApiResponse> {
  return request<ApiResponse>('/api/esp32/center', {
    method: 'POST',
  })
}

export async function setEsp32Speed(mode: number): Promise<ApiResponse> {
  return request<ApiResponse>('/api/esp32/speed', {
    method: 'POST',
    body: JSON.stringify({ mode }),
  })
}