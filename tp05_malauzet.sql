-- 2) a. Listez les articles dans l’ordre alphabétique des désignations
SELECT * FROM ARTICLE
ORDER BY DESIGNATION;

-- 2) b. Listez les articles dans l’ordre des prix du plus élevé au moins élevé
SELECT * FROM ARTICLE
ORDER BY PRIX DESC;

-- 2) c. Listez tous les articles qui sont des « boulons » et triez les résultats par ordre de prix ascendant
SELECT * FROM ARTICLE
WHERE DESIGNATION LIKE '%boulon%'
ORDER BY PRIX;

-- 2) d. Listez tous les articles dont la désignation contient le mot « sachet ».
SELECT * FROM ARTICLE
WHERE DESIGNATION LIKE '%sachet%';

-- 2) e. Listez tous les articles dont la désignation contient le mot « sachet » indépendamment de la casse !
SELECT * FROM ARTICLE
WHERE DESIGNATION LIKE '%sachet%';

-- 2) f. Listez les articles avec les informations fournisseur correspondantes. Les résultats doivent être triées dans l’ordre alphabétique des fournisseurs et par article du prix le plus élevé au moins élevé.
SELECT A.*, F.NOM
FROM ARTICLE A
	JOIN FOURNISSEUR F ON A.ID_FOU = F.ID
ORDER BY F.NOM ASC, A.PRIX DESC;

-- 2) g. Listez les articles de la société « Dubois & Fils »
SELECT A.*
FROM ARTICLE A
	JOIN FOURNISSEUR F ON A.ID_FOU = F.ID
WHERE F.NOM = 'Dubois & Fils';

-- 2) h. Calculez la moyenne des prix des articles de la société « Dubois & Fils »
SELECT AVG(A.PRIX) AS PRIX_MOYEN
FROM ARTICLE A
	JOIN FOURNISSEUR F ON A.ID_FOU = F.ID
WHERE F.NOM = 'Dubois & Fils';

-- 2) i. Calculez la moyenne des prix des articles de chaque fournisseur
SELECT F.NOM, AVG(A.PRIX) AS PRIX_MOYEN
FROM ARTICLE A
	JOIN FOURNISSEUR F ON A.ID_FOU = F.ID
GROUP BY F.ID, F.NOM;

-- 2) j. Sélectionnez tous les bons de commandes émis entre le 01/03/2019 et le 05/04/2019 à 12h00.
SELECT * FROM BON
WHERE DATE_CMDE BETWEEN '2019-03-01' AND '2019-04-05 12:00:00';

-- 2) k. Sélectionnez les divers bons de commande qui contiennent des boulons
SELECT DISTINCT B.*
FROM BON B
	JOIN COMPO C ON C.ID_BON = B.ID
	JOIN ARTICLE A ON A.ID = C.ID_ART
WHERE A.DESIGNATION LIKE '%boulon%';

-- 2) l. Sélectionnez les divers bons de commande qui contiennent des boulons avec le nom du fournisseur associé.
SELECT DISTINCT B.*, F.NOM
FROM BON B
	JOIN COMPO C ON C.ID_BON = B.ID
	JOIN ARTICLE A ON A.ID = C.ID_ART
	JOIN FOURNISSEUR F ON F.ID = B.ID_FOU
WHERE A.DESIGNATION LIKE '%boulon%';

-- 2) m. Calculez le prix total de chaque bon de commande
SELECT B.ID, B.NUMERO, SUM(A.PRIX * C.QTE) AS PRIX_TOTAL
FROM BON B
	JOIN COMPO C ON C.ID_BON = B.ID
	JOIN ARTICLE A ON A.ID = C.ID_ART
GROUP BY B.ID, B.NUMERO;

-- 2) n. Comptez le nombre d’articles de chaque bon de commande
SELECT B.ID, B.NUMERO, COUNT(C.ID_ART) AS NB_ARTICLES
FROM BON B
	JOIN COMPO C ON C.ID_BON = B.ID
GROUP BY B.ID, B.NUMERO;

-- 2) o. Affichez les numéros de bons de commande qui contiennent plus de 25 articles et affichez le nombre d’articles de chacun de ces bons de commande
SELECT B.NUMERO, SUM(C.QTE) AS NB_ARTICLES
FROM BON B
	JOIN COMPO C ON C.ID_BON = B.ID
GROUP BY B.ID, B.NUMERO
HAVING NB_ARTICLES > 25;

-- 2) p. Calculez le coût total des commandes effectuées sur le mois d’avril
SELECT SUM(A.PRIX * C.QTE) AS COUT_TOTAL_AVRIL
FROM BON B
	JOIN COMPO C ON C.ID_BON = B.ID
	JOIN ARTICLE A ON A.ID = C.ID_ART
WHERE MONTH(B.DATE_CMDE) = 4;

-- 3) a. Sélectionnez les articles qui ont une désignation identique mais des fournisseurs différents (indice : réaliser une auto-jointure i.e. de la table avec elle-même)
SELECT A1.ID AS ID_ARTICLE_1, A1.REF AS REF_1, A1.DESIGNATION, A1.ID_FOU AS FOURNISSEUR_1,
       A2.ID AS ID_ARTICLE_2, A2.REF AS REF_2, A2.ID_FOU AS FOURNISSEUR_2
FROM ARTICLE A1
	JOIN ARTICLE A2 ON A1.DESIGNATION = A2.DESIGNATION
	AND A1.ID_FOU != A2.ID_FOU
	AND A1.ID < A2.ID;

-- 3) b. Calculez les dépenses en commandes mois par mois (indice : utilisation des fonctions MONTH et YEAR)
SELECT YEAR(B.DATE_CMDE) AS ANNEE, MONTH(B.DATE_CMDE) AS MOIS, SUM(A.PRIX * C.QTE) AS DEPENSE_TOTALE
FROM BON B
	JOIN COMPO C ON C.ID_BON = B.ID
	JOIN ARTICLE A ON A.ID = C.ID_ART
GROUP BY YEAR(B.DATE_CMDE), MONTH(B.DATE_CMDE)
ORDER BY ANNEE, MOIS;

-- 3) c. Sélectionnez les bons de commandes sans article (indice : utilisation de EXISTS)
SELECT B.*
FROM BON B
WHERE NOT EXISTS (
    SELECT *
    FROM COMPO C
    WHERE C.ID_BON = B.ID
);

-- 3) d. Calculez le prix moyen des bons de commande par fournisseur.
SELECT F.NOM, AVG(TOTAUX.PRIX_TOTAL) AS PRIX_MOYEN_BON
FROM (
    SELECT B.ID, B.ID_FOU, SUM(A.PRIX * C.QTE) AS PRIX_TOTAL
    FROM BON B
    	JOIN COMPO C ON C.ID_BON = B.ID
    	JOIN ARTICLE A ON A.ID = C.ID_ART
    GROUP BY B.ID, B.ID_FOU
) AS TOTAUX
	JOIN FOURNISSEUR F ON F.ID = TOTAUX.ID_FOU
GROUP BY F.ID, F.NOM;