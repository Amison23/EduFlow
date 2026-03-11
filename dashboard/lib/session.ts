import Cookies from 'js-cookie';

/**
 * Decode JWT payload without a library (client-side only).
 * Returns null if the token is malformed.
 */
function decodeJwtPayload(token: string): Record<string, any> | null {
    try {
        const parts = token.split('.');
        if (parts.length !== 3) return null;
        const payload = atob(parts[1].replace(/-/g, '+').replace(/_/g, '/'));
        return JSON.parse(payload);
    } catch {
        return null;
    }
}

/**
 * Returns the number of seconds until the token expires.
 * Returns 0 if the token is expired or invalid.
 */
export function getTokenSecondsRemaining(): number {
    const token = Cookies.get('accessToken');
    if (!token) return 0;
    const payload = decodeJwtPayload(token);
    if (!payload?.exp) return 0;
    return Math.max(0, payload.exp - Math.floor(Date.now() / 1000));
}

/**
 * Returns true if the current session token is expired or missing.
 */
export function isSessionExpired(): boolean {
    return getTokenSecondsRemaining() === 0;
}

/**
 * Clears all admin session data from cookies and localStorage.
 */
export function clearSession(): void {
    Cookies.remove('accessToken');
    Cookies.remove('refreshToken');
    if (typeof window !== 'undefined') {
        localStorage.removeItem('adminUser');
    }
}

/**
 * Clears the session and redirects to the login page.
 * @param reason - optional query string reason: 'expired' | 'unauthorized'
 */
export function forceLogout(reason: 'expired' | 'unauthorized' = 'expired'): void {
    clearSession();
    if (typeof window !== 'undefined') {
        window.location.href = `/?session=${reason}`;
    }
}
