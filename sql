CREATE TABLE public.client (
	id serial4 NOT NULL,
	login varchar NULL,
	firstname varchar NULL,
	lastname varchar NULL,
	email varchar NULL,
	CONSTRAINT client_pkey PRIMARY KEY (id),
	CONSTRAINT login_unique UNIQUE (login)
);

create trigger new_client after
insert
    on
    public.client for each row execute function create_user();
create trigger delete_user before
delete
    on
    public.client for each row execute function delete_user();
	
CREATE OR REPLACE FUNCTION public.create_user()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
	BEGIN
insert into "client_save" ("client_id" , "pass") values (new.id, null);
return new;
	END;
$function$
;

CREATE OR REPLACE FUNCTION public.delete_user()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
	BEGIN
DELETE FROM public.client_save
	WHERE client_id=old.id;
UPDATE public.chat 
SET id_sender = '0'
WHERE id_sender = old.id;
UPDATE public.chat 
SET id_recipient = '0'
WHERE id_recipient = old.id;
return old;
	END;
$function$
;

CREATE TABLE public.chat (
	id_sender int4 NOT NULL,
	id_recipient int4 NOT NULL,
	id serial4 NOT NULL,
	CONSTRAINT id PRIMARY KEY (id),
	CONSTRAINT chat_fk FOREIGN KEY (id_sender) REFERENCES public.client(id),
	CONSTRAINT chat_fk_1 FOREIGN KEY (id_recipient) REFERENCES public.client(id)
);

CREATE TABLE public.client_save (
	client_id serial4 NOT NULL,
	pass varchar NULL,
	CONSTRAINT client_save_pkey PRIMARY KEY (client_id),
	CONSTRAINT client_save_fk FOREIGN KEY (client_id) REFERENCES public.client(id)
);

CREATE TABLE public.message (
	chat_id int4 NOT NULL DEFAULT nextval('message_id_seq'::regclass),
	message text NOT NULL,
	send_time timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	status int4 NOT NULL,
	CONSTRAINT message_pkey PRIMARY KEY (chat_id),
	CONSTRAINT message_fk FOREIGN KEY (chat_id) REFERENCES public.chat(id)
);
 psql -Upostgres -hlocalhost -dpostgres

INSERT INTO public.client (login,firstname,lastname,email) VALUES
	 (NULL,'User deleted.',NULL,NULL),
	 ('Test','Tester','Testerov','test@test.ru'),
	 ('Viko','Olaf','Viking','Olaf@north.se'),
	 ('Vikb','Baleog','Viking','Baleog@north.se'),
	 ('Tip','ТипичноеИмя','ТипичнаяФамилия','typical@typical.ru'),
	 ('Vik','Eric','Viking','Erick@north.se'),
	 ('Rus','такое_же_длинное_имя_с_нестандартными_символами_#!@$#?\_','Проверка_Поля_на_достаточно_длинную_и_нестандартную_фамилию','почта@русская.ру.');
