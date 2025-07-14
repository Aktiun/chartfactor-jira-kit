set timezone to 'UTC';

UPDATE public.ticket_sales SET saletime_utc = saletime;

UPDATE public.ticket_sales SET saletime_min_7 = timezone('PDT', saletime);
UPDATE public.ticket_sales SET saletime_plus_8 = timezone('PST', saletime);