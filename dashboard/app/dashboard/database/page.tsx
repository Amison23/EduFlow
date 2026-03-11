'use client';

import { useState } from 'react';
import { api } from '@/lib/api';

export default function DatabaseExplorer() {
    const [query, setQuery] = useState('LIST_TABLES');
    const [results, setResults] = useState<any[]>([]);
    const [tables, setTables] = useState<string[]>([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const runQuery = async () => {
        setLoading(true);
        setError('');
        try {
            const data = await api.post('/admin/query', { query });
            if (data.tables) setTables(data.tables);
            if (data.results) setResults(data.results);
        } catch (err: any) {
            setError(err.message || 'Failed to execute query');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-6">
            <h1 className="text-3xl font-bold text-gray-900">Database Explorer</h1>
            
            <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <label className="block text-sm font-medium text-gray-700 mb-2">Safe SQL Query (SELECT only)</label>
                <div className="flex gap-4">
                    <input 
                        type="text" 
                        value={query}
                        onChange={(e) => setQuery(e.target.value)}
                        placeholder="SELECT * FROM learners..."
                        className="flex-1 border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500 outline-none"
                    />
                    <button 
                        onClick={runQuery}
                        disabled={loading}
                        className="bg-gray-900 text-white px-6 py-2 rounded-lg font-medium hover:bg-black transition disabled:opacity-50"
                    >
                        {loading ? 'Running...' : 'Run Query'}
                    </button>
                </div>
                {error && <p className="mt-2 text-sm text-red-600 font-medium">{error}</p>}
            </div>

            {tables.length > 0 && (
                <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                    <h3 className="text-lg font-semibold mb-4">Available Tables</h3>
                    <div className="flex flex-wrap gap-2">
                        {tables.map(t => (
                            <button 
                                key={t} 
                                onClick={() => { setQuery(`SELECT * FROM ${t}`); runQuery(); }}
                                className="px-3 py-1 bg-blue-50 text-blue-700 rounded-md text-sm border border-blue-100 hover:bg-blue-100"
                            >
                                {t}
                            </button>
                        ))}
                    </div>
                </div>
            )}

            {results.length > 0 && (
                <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50">
                                <tr>
                                    {Object.keys(results[0]).map(key => (
                                        <th key={key} className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">{key}</th>
                                    ))}
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-200">
                                {results.map((row, i) => (
                                    <tr key={i} className="hover:bg-gray-50">
                                        {Object.values(row).map((val: any, j) => (
                                            <td key={j} className="px-4 py-3 text-sm text-gray-600 truncate max-w-xs">
                                                {typeof val === 'object' ? JSON.stringify(val) : String(val)}
                                            </td>
                                        ))}
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}
        </div>
    );
}
