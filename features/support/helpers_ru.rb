module HelpersRu
  def valor_em_reais(texto)
    BigDecimal(texto.delete("R$ ").tr(",", "."))
  end

  def codigo_de_status(texto)
    texto.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase.tr(" ", "_")
  end

  # Os .feature usam ALUNO/FUNCIONARIO/ADMIN; o model (autenticação do Pedro) usa estudante/funcionario/administrador.
  PERFIS_DO_FEATURE = { "ALUNO" => "estudante", "FUNCIONARIO" => "funcionario", "ADMIN" => "administrador" }.freeze

  def perfil_do_model(texto)
    PERFIS_DO_FEATURE.fetch(texto)
  end

  # Estudante: 9 dígitos. Funcionário/administrador: 7 dígitos (SIAPE).
  def proxima_matricula(perfil)
    @contador_matriculas = (@contador_matriculas || 0) + 1
    perfil == "estudante" ? format("8%08d", @contador_matriculas) : format("9%06d", @contador_matriculas)
  end
end

World(HelpersRu)
