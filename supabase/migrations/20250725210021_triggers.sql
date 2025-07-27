CREATE OR REPLACE FUNCTION public.handle_jury_deletion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Cancella il voting_form corrispondente usando l'ID memorizzato
  -- nella riga della giuria che sta per essere eliminata.
  -- 'OLD' è un record speciale che contiene i valori della riga
  -- prima dell'operazione di DELETE.
  DELETE FROM public.voting_forms WHERE id = OLD.voting_form_id;

  -- Permette all'operazione di DELETE originale di procedere.
  RETURN OLD;
END;
$$;

-- Crea un trigger che si attiva PRIMA di ogni DELETE sulla tabella 'juries'.
CREATE TRIGGER on_jury_delete_cascade_voting_form
AFTER DELETE ON public.juries
FOR EACH ROW
EXECUTE FUNCTION public.handle_jury_deletion();


-- 1. Crea la funzione che verrà eseguita dal trigger.
--    Questa funzione si occupa di cancellare il 'place' associato.
CREATE OR REPLACE FUNCTION public.handle_contest_deletion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- 'OLD' è un record speciale che contiene i valori della riga
  -- che sta per essere eliminata dalla tabella 'contests'.
  -- Usiamo OLD.place_id per trovare e cancellare il record corrispondente in 'places'.
  DELETE FROM public.places WHERE id = OLD.place_id;

  -- Per i trigger di tipo AFTER DELETE, il valore di ritorno viene ignorato,
  -- ma è buona norma restituire OLD.
  RETURN OLD;
END;
$$;

-- 2. Crea il trigger che si attiva DOPO ogni operazione di DELETE sulla tabella 'contests'.
CREATE TRIGGER on_contest_delete_cascade_place
-- Si attiva DOPO che la cancellazione del contest è avvenuta con successo.
AFTER DELETE ON public.contests
-- Esegue la funzione per ogni singola riga cancellata.
FOR EACH ROW
-- Specifica quale funzione eseguire.
EXECUTE FUNCTION public.handle_contest_deletion();

