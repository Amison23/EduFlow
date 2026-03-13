const supabase = require('../config/supabase');

/**
 * Upload a file to Supabase Storage
 * @param {string} bucket - The bucket name
 * @param {string} path - The path inside the bucket
 * @param {Buffer} fileBuffer - The file content
 * @param {string} contentType - The MIME type
 * @returns {Promise<string>} - The public URL of the uploaded file
 */
exports.uploadFile = async (bucket, path, fileBuffer, contentType) => {
    try {
        const { data, error } = await supabase.storage
            .from(bucket)
            .upload(path, fileBuffer, {
                contentType,
                upsert: true
            });

        if (error) throw error;

        const { data: { publicUrl } } = supabase.storage
            .from(bucket)
            .getPublicUrl(path);

        return publicUrl;
    } catch (error) {
        console.error('Storage upload error:', error);
        throw error;
    }
};

/**
 * Delete a file from Supabase Storage
 * @param {string} bucket - The bucket name
 * @param {string} path - The path inside the bucket
 */
exports.deleteFile = async (bucket, path) => {
    try {
        const { error } = await supabase.storage
            .from(bucket)
            .remove([path]);

        if (error) throw error;
    } catch (error) {
        console.error('Storage delete error:', error);
        // Don't throw if delete fails, just log it
    }
};
