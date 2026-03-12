import { createClient } from '@supabase/supabase-js';
import Cookies from 'js-cookie';
import { forceLogout } from './session';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1';

/**
 * Fetch with Automatic Token Refresh & Graceful Session Expiry
 */
async function apiFetch(endpoint: string, options: RequestInit = {}, _retried = false): Promise<any> {
    const token = Cookies.get('accessToken');

    const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
        ...(options.headers as Record<string, string>),
    };

    let response: Response;
    try {
        response = await fetch(`${API_BASE_URL}${endpoint}`, {
            ...options,
            headers,
        });
    } catch (error: any) {
        // Network/Connection errors
        await api.logError({
            level: 'error',
            message: `Network error: ${error.message}`,
            source: 'dashboard',
            context: { endpoint, method: options.method || 'GET' }
        });
        throw error;
    }

    // Handle 401 Unauthorized
    if (response.status === 401) {
        // Skip refresh for login endpoint itself to avoid loops
        if (endpoint === '/admin/login' || endpoint === '/logs') {
            const error = await response.json().catch(() => ({}));
            throw new Error(error.error || 'Invalid credentials');
        }

        // Attempt token refresh if a refresh token is present
        if (!_retried) {
            const refreshToken = Cookies.get('refreshToken');
            if (refreshToken) {
                const refreshRes = await fetch(`${API_BASE_URL}/auth/refresh-token`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ refreshToken }),
                });

                if (refreshRes.ok) {
                    const refreshed = await refreshRes.json();
                    const newAccessToken = refreshed.token || refreshed.accessToken;
                    const newRefreshToken = refreshed.refreshToken;

                    Cookies.set('accessToken', newAccessToken, { expires: 7 });
                    if (newRefreshToken) Cookies.set('refreshToken', newRefreshToken, { expires: 30 });

                    // Retry once with the new token
                    return apiFetch(endpoint, options, true);
                }
            }
        }

        // No refresh token or refresh failed — session is expired
        forceLogout('expired');
        throw new Error('Session expired. Please log in again.');
    }

    // Handle 403 Forbidden — unauthorized role
    if (response.status === 403) {
        const error = await response.json().catch(() => ({}));
        throw new Error(error.error || 'Access denied. Insufficient permissions.');
    }

    if (!response.ok) {
        const error = await response.json().catch(() => ({}));
        const errorMessage = error.error || error.message || `Request failed (${response.status})`;

        // Automatically log 500-level errors to the backend
        if (response.status >= 500 && endpoint !== '/logs') {
            api.logError({
                level: 'critical',
                message: `Server Error: ${errorMessage}`,
                source: 'dashboard',
                context: {
                    endpoint,
                    method: options.method || 'GET',
                    statusCode: response.status,
                    errorData: error
                }
            }).catch(e => console.error('Failed to report error to backend:', e));
        }

        throw new Error(errorMessage);
    }

    return response.json();
}

export const api = {
    get: (endpoint: string) => apiFetch(endpoint, { method: 'GET' }),
    post: (endpoint: string, body: any) => apiFetch(endpoint, {
        method: 'POST',
        body: JSON.stringify(body)
    }),
    put: (endpoint: string, body: any) => apiFetch(endpoint, {
        method: 'PUT',
        body: JSON.stringify(body)
    }),
    delete: (endpoint: string) => apiFetch(endpoint, { method: 'DELETE' }),
    logError: (data: { level: string; message: string; source: string; context?: any; stackTrace?: string }) => 
        apiFetch('/logs', {
            method: 'POST',
            body: JSON.stringify(data)
        }),
    getLearners: () => apiFetch('/auth/learners'),
    getAnalytics: () => apiFetch('/analytics/overview'),
    getDetailedAnalytics: () => apiFetch('/analytics/detailed'),
    getLessonPacks: () => apiFetch('/lessons/packs'),
    getLanguages: () => apiFetch('/languages'),
    addLanguage: (data: any) => apiFetch('/languages', { method: 'POST', body: JSON.stringify(data) }),
    updateLanguage: (id: string, data: any) => apiFetch(`/languages/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
    deleteLanguage: (id: string) => apiFetch(`/languages/${id}`, { method: 'DELETE' }),
    getOrgSettings: (key?: string) => apiFetch(`/organization/settings?key=${key || 'global_config'}`),
    updateOrgSettings: (key: string, value: any) => apiFetch('/organization/settings', {
        method: 'PUT',
        body: JSON.stringify({ key, value })
    }),
    updateProfile: (data: any) => apiFetch('/auth/update-profile', { method: 'POST', body: JSON.stringify(data) }),
    // Admin Management
    getAllAdmins: () => apiFetch('/admin/admins'),
    createAdmin: (data: any) => apiFetch('/admin/admins', { method: 'POST', body: JSON.stringify(data) }),
    deleteAdmin: (id: string) => apiFetch(`/admin/admins/${id}`, { method: 'DELETE' }),
};
