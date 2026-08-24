const { createClient } = require("@supabase/supabase-js");

const json = (response, statusCode, body) => {
  response.statusCode = statusCode;
  response.setHeader("Content-Type", "application/json; charset=utf-8");
  response.end(JSON.stringify(body));
};

module.exports = async function handler(request, response) {
  if (request.method !== "POST") {
    response.setHeader("Allow", "POST");
    return json(response, 405, { error: "Metodo nao permitido" });
  }

  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !serviceRoleKey) {
    return json(response, 500, {
      error: "Variaveis SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY precisam estar configuradas na Vercel."
    });
  }

  const chunks = [];
  for await (const chunk of request) chunks.push(chunk);

  let payload = {};
  try {
    payload = JSON.parse(Buffer.concat(chunks).toString("utf8") || "{}");
  } catch {
    return json(response, 400, { error: "JSON invalido" });
  }

  const email = String(payload.email || "").trim().toLowerCase();
  if (!email) return json(response, 400, { error: "E-mail obrigatorio" });

  const redirectTo = String(payload.redirectTo || process.env.SUPABASE_INVITE_REDIRECT || "").trim() || undefined;
  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false }
  });

  const { data, error } = await supabase.auth.admin.inviteUserByEmail(email, {
    redirectTo,
    data: {
      nome: payload.nome || "",
      crm: payload.crm || "",
      origem: "sobramid-ba-conecta"
    }
  });

  if (error) return json(response, 400, { error: error.message });

  return json(response, 200, {
    ok: true,
    userId: data?.user?.id || null,
    email
  });
};
