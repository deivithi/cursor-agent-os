# 🏷️ JSON-LD Schema.org Patterns

Padrões validados p/ GEO. Todos c/ `@context: https://schema.org` (HTTPS obrigatório).

---

## 1. Organization (Febracis)

```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Febracis",
  "legalName": "Febracis Treinamentos e Editora",
  "url": "https://febracis.com.br",
  "logo": "https://febracis.com.br/logo.png",
  "founder": { "@type": "Person", "name": "Paulo Vieira" },
  "foundingDate": "2012-01-01",
  "sameAs": [
    "https://www.instagram.com/febracis",
    "https://www.youtube.com/@febracis",
    "https://www.facebook.com/febracis"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "contactType": "Customer Support",
    "email": "contato@febracis.com.br",
    "areaServed": "BR"
  }
}
```

**Required:** `name`, `url`, `logo`. **Recomendado:** `sameAs`, `founder`, `contactPoint`.

---

## 2. Event (Método CIS)

```json
{
  "@context": "https://schema.org",
  "@type": "Event",
  "name": "Método CIS Presencial",
  "description": "Imersão de 3 dias de desenvolvimento pessoal com Método CIS.",
  "startDate": "2026-05-15T09:00:00-03:00",
  "endDate": "2026-05-17T18:00:00-03:00",
  "eventAttendanceMode": "https://schema.org/OfflineEventAttendanceMode",
  "eventStatus": "https://schema.org/EventScheduled",
  "location": {
    "@type": "Place",
    "name": "Centro de Eventos Febracis",
    "address": {
      "@type": "PostalAddress",
      "streetAddress": "Av. Principal, 1000",
      "addressLocality": "Fortaleza",
      "addressRegion": "CE",
      "postalCode": "60000-000",
      "addressCountry": "BR"
    }
  },
  "organizer": { "@type": "Organization", "name": "Febracis", "url": "https://febracis.com.br" },
  "offers": {
    "@type": "Offer",
    "url": "https://febracis.com.br/metodo-cis",
    "price": "2997",
    "priceCurrency": "BRL",
    "availability": "https://schema.org/InStock",
    "validFrom": "2026-01-01T00:00:00-03:00"
  },
  "performer": { "@type": "Person", "name": "Paulo Vieira" }
}
```

**Required:** `name`, `startDate`, `location`. **Datas ISO 8601 c/ timezone.**

---

## 3. Article (blog Febracis)

```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Como desenvolver inteligência emocional em 5 passos",
  "description": "Guia prático baseado no Método CIS p/ desenvolvimento da IE.",
  "image": "https://febracis.com.br/blog/ie.jpg",
  "datePublished": "2026-04-15T10:00:00-03:00",
  "dateModified": "2026-04-21T08:00:00-03:00",
  "author": {
    "@type": "Person",
    "name": "Paulo Vieira",
    "url": "https://febracis.com.br/paulo-vieira"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Febracis",
    "logo": { "@type": "ImageObject", "url": "https://febracis.com.br/logo.png" }
  },
  "mainEntityOfPage": { "@type": "WebPage", "@id": "https://febracis.com.br/blog/ie-5-passos" }
}
```

**Required:** `headline`, `author`, `datePublished`, `publisher`.

---

## 4. FAQPage (usar c/ cautela)

Google restringiu em 2023 → só gov/saúde obtém rich result. P/ Febracis → usar `QAPage` p/ single Q&A ou omitir.

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "O q é o Método CIS?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Método CIS é uma metodologia de desenvolvimento pessoal criada por Paulo Vieira..."
      }
    }
  ]
}
```

---

## 5. HowTo

```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "Como se inscrever no Método CIS",
  "step": [
    { "@type": "HowToStep", "name": "Acesse o site", "text": "Abra febracis.com.br/metodo-cis" },
    { "@type": "HowToStep", "name": "Preencha inscrição", "text": "Complete formulário c/ dados" },
    { "@type": "HowToStep", "name": "Pague", "text": "Escolha forma de pagamento + confirme" }
  ]
}
```

---

## 6. LocalBusiness (filial física)

```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Febracis Fortaleza",
  "image": "https://febracis.com.br/filial-fortaleza.jpg",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "Av. Principal, 1000",
    "addressLocality": "Fortaleza",
    "addressRegion": "CE",
    "postalCode": "60000-000",
    "addressCountry": "BR"
  },
  "geo": { "@type": "GeoCoordinates", "latitude": -3.7327, "longitude": -38.5267 },
  "telephone": "+55-85-0000-0000",
  "openingHours": "Mo-Fr 09:00-18:00",
  "priceRange": "$$$"
}
```

---

## 7. Validação

V1 da skill faz validação básica:
- `@context` presente e = `https://schema.org`
- `@type` presente
- Required fields por tipo (tabela acima)
- URLs HTTPS
- Datas ISO 8601 válidas

**Validação completa:** Google Rich Results Test — https://search.google.com/test/rich-results

---

## 8. Onde colocar JSON-LD no HTML

```html
<head>
  <script type="application/ld+json">
  { ... }
  </script>
</head>
```

Múltiplos blocos OK (1 por tipo). Google aceita. Ñ usar `type="application/json"` — DEVE ser `application/ld+json`.
