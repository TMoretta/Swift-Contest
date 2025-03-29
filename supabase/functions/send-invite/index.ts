// send-invite/index.ts
import { serve } from "https://deno.land/std@0.140.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const RESEND_API_URL = "https://api.resend.com/email";

serve(async (req: Request) => {
  try {
    const { email, subject, html } = await req.json();

    const response = await fetch(RESEND_API_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: 'Resend <onboarding@resend.dev>',
        to: [email],
        subject: subject,
        html: html,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      return new Response(`Error sending email: ${errorText}`, { status: response.status });
    }

    return new Response("Email sent successfully!", { status: 200 });
  } catch (error) {
    return new Response("Internal Server Error: " + error, { status: 500 });
  }
});

// import { serve } from "https://deno.land/std@0.140.0/http/server.ts";
//
// const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
// const RESEND_API_URL = "https://api.resend.com/email";
//
// serve(async (req: Request) => {
//   if (req.method === "OPTIONS") {
//     return new Response(null, {
//       status: 204,
//       headers: {
//         "Access-Control-Allow-Origin": "*",
//         "Access-Control-Allow-Methods": "POST, OPTIONS",
//         "Access-Control-Allow-Headers": "Content-Type, Authorization",
//       },
//     });
//   }
//
//   try {
//     const { email, subject, html } = await req.json();
//
//     const response = await fetch(RESEND_API_URL, {
//       method: "POST",
//       headers: {
//         "Authorization": `Bearer ${RESEND_API_KEY}`,
//         "Content-Type": "application/json",
//       },
//       body: JSON.stringify({
//         from: 'Resend <onboarding@resend.dev>',
//         to: [email],
//         subject: subject,
//         html: html,
//       }),
//     });
//
//     if (!response.ok) {
//       const errorText = await response.text();
//       return new Response(`Error sending email: ${errorText}`, { status: response.status });
//     }
//
//     return new Response("Email sent successfully!", {
//       status: 200,
//       headers: {
//         "Access-Control-Allow-Origin": "*",
//       },
//     });
//   } catch (error) {
//     return new Response("Internal Server Error: " + error, {
//       status: 500,
//       headers: {
//         "Access-Control-Allow-Origin": "*",
//       },
//     });
//   }
// });
