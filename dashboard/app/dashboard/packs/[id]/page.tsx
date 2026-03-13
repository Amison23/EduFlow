'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { api } from '@/lib/api';
import { ArrowLeft, Music, Upload, CheckCircle, AlertCircle, Loader2 } from 'lucide-react';
import Link from 'next/link';

export default function PackLessonsPage() {
    const { id } = useParams();
    const router = useRouter();
    const [pack, setPack] = useState<any>(null);
    const [lessons, setLessons] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [uploadingId, setUploadingId] = useState<string | null>(null);
    const [uploadStatus, setUploadStatus] = useState<{[key: string]: 'idle' | 'uploading' | 'success' | 'error'}>({});

    useEffect(() => {
        if (!id) return;
        
        const fetchData = async () => {
            try {
                // Fetch pack details
                const packs = await api.get('/lessons/packs');
                const currentPack = packs.find((p: any) => p.id === id);
                setPack(currentPack);

                // Fetch lessons for this pack
                const lessonsData = await api.get(`/lessons/packs/${id}/lessons`);
                setLessons(lessonsData);
                
                // Initialize upload status
                const initialStatus: any = {};
                lessonsData.forEach((l: any) => initialStatus[l.id] = 'idle');
                setUploadStatus(initialStatus);

                setLoading(false);
            } catch (err) {
                console.error('Failed to fetch pack data:', err);
                setLoading(false);
            }
        };

        fetchData();
    }, [id]);

    const handleAudioUpload = async (lessonId: string, file: File) => {
        if (!file) return;

        setUploadingId(lessonId);
        setUploadStatus(prev => ({ ...prev, [lessonId]: 'uploading' }));

        try {
            const formData = new FormData();
            formData.append('audio', file);

            const result = await api.post(`/lessons/${lessonId}/audio`, formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });

            // Update local lesson state
            setLessons(prev => prev.map(l => 
                l.id === lessonId ? { ...l, audio_url: result.audioUrl } : l
            ));

            setUploadStatus(prev => ({ ...prev, [lessonId]: 'success' }));
            setTimeout(() => {
                setUploadStatus(prev => ({ ...prev, [lessonId]: 'idle' }));
            }, 3000);
        } catch (err) {
            console.error('Upload failed:', err);
            setUploadStatus(prev => ({ ...prev, [lessonId]: 'error' }));
            alert('Failed to upload audio file. Please ensure it is an MP3.');
        } finally {
            setUploadingId(null);
        }
    };

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center py-20">
                <Loader2 className="h-8 w-8 text-blue-600 animate-spin mb-4" />
                <p className="text-gray-500">Loading lesson pack details...</p>
            </div>
        );
    }

    if (!pack) {
        return (
            <div className="py-20 text-center">
                <AlertCircle className="h-12 w-12 text-red-500 mx-auto mb-4" />
                <h2 className="text-xl font-bold text-gray-900">Pack not found</h2>
                <Link href="/dashboard/packs" className="text-blue-600 hover:underline mt-2 inline-block">
                    Return to packs listing
                </Link>
            </div>
        );
    }

    return (
        <div className="pb-12">
            <div className="mb-6">
                <Link href="/dashboard/packs" className="flex items-center text-sm text-gray-500 hover:text-blue-600 transition mb-4 group">
                    <ArrowLeft className="h-4 w-4 mr-1 group-hover:-translate-x-1 transition-transform" />
                    Back to Packs
                </Link>
                <div className="flex justify-between items-end">
                    <div>
                        <h1 className="text-3xl font-bold text-gray-900 tracking-tight">{pack.subject}</h1>
                        <p className="text-gray-500 mt-1">
                            Level {pack.level} • {pack.language.toUpperCase()} • {lessons.length} Lessons
                        </p>
                    </div>
                </div>
            </div>

            <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-gray-50 border-b border-gray-200">
                                <th className="px-6 py-4 text-xs font-bold text-gray-500 uppercase tracking-wider w-16">Seq</th>
                                <th className="px-6 py-4 text-xs font-bold text-gray-500 uppercase tracking-wider">Lesson Title</th>
                                <th className="px-6 py-4 text-xs font-bold text-gray-500 uppercase tracking-wider">Audio Status</th>
                                <th className="px-6 py-4 text-xs font-bold text-gray-500 uppercase tracking-wider text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {lessons.map((lesson) => (
                                <tr key={lesson.id} className="hover:bg-gray-50 transition-colors">
                                    <td className="px-6 py-4 text-sm font-medium text-gray-400">
                                        {lesson.sequence}
                                    </td>
                                    <td className="px-6 py-4">
                                        <div className="text-sm font-semibold text-gray-900">{lesson.title}</div>
                                        <div className="text-xs text-gray-500 line-clamp-1 mt-0.5">{lesson.id}</div>
                                    </td>
                                    <td className="px-6 py-4">
                                        {lesson.audio_url ? (
                                            <div className="flex items-center text-green-600">
                                                <CheckCircle className="h-4 w-4 mr-1.5" />
                                                <span className="text-xs font-medium">Synced</span>
                                                <a 
                                                    href={lesson.audio_url} 
                                                    target="_blank" 
                                                    rel="noopener noreferrer"
                                                    className="ml-2 text-[10px] text-blue-500 hover:underline"
                                                >
                                                    Preview
                                                </a>
                                            </div>
                                        ) : (
                                            <div className="flex items-center text-gray-400">
                                                <AlertCircle className="h-4 w-4 mr-1.5" />
                                                <span className="text-xs">No Audio</span>
                                            </div>
                                        )}
                                    </td>
                                    <td className="px-6 py-4 text-right">
                                        <div className="flex justify-end items-center space-x-3">
                                            {uploadStatus[lesson.id] === 'uploading' ? (
                                                <div className="flex items-center text-blue-600 text-xs font-medium">
                                                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                                                    Uploading...
                                                </div>
                                            ) : uploadStatus[lesson.id] === 'success' ? (
                                                <div className="text-green-600 text-xs font-bold flex items-center">
                                                    <CheckCircle className="h-4 w-4 mr-1" />
                                                    Done!
                                                </div>
                                            ) : (
                                                <label className="cursor-pointer bg-white border border-gray-200 text-gray-700 px-3 py-1.5 rounded-lg text-xs font-bold hover:bg-gray-50 transition flex items-center shadow-sm">
                                                    <Music className="h-3.5 w-3.5 mr-1.5 text-blue-600" />
                                                    {lesson.audio_url ? 'Update Audio' : 'Add Audio'}
                                                    <input 
                                                        type="file" 
                                                        accept="audio/mpeg" 
                                                        className="hidden" 
                                                        onChange={(e) => {
                                                            const file = e.target.files?.[0];
                                                            if (file) handleAudioUpload(lesson.id, file);
                                                        }}
                                                    />
                                                </label>
                                            )}
                                            <button className="text-gray-400 hover:text-gray-600 p-1">
                                                <Upload className="h-4 w-4" />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
