-- Autorise tous les formats vidéo dans le bucket réalisations (validation côté app).

update storage.buckets
set allowed_mime_types = null
where id = 'realisation-photos';
