***Settings***
Library     RequestsLibrary
Library     Collections

***Variables***
${URL}      http://superheroapi.com/api/4385634404811012

***Keywords***
Dado que esteja conectado na SuperHeroAPI
    Create Session      sessao      ${URL}

Quando requisitar o histórico do super herói "${nome_heroi}"
    ${pesquisa_id}          Get Request         sessao      /search/${nome_heroi}
    ${id}                   Pesquisa heroID     ${pesquisa_id}      ${nome_heroi}
    ${resposta}             Get Request         sessao      /${id}
    Set Test Variable       ${resposta}

Então deve ser retornado que a sua inteligência é superior a "${inteligencia}"
    log                         ${resposta.json()}
    ${pwrstt_intelligence}      Get from Dictionary       ${resposta.json()['powerstats']}    intelligence
    Convert to Number           ${pwrstt_intelligence}
    Should Be True              ${pwrstt_intelligence} > ${inteligencia}

E deve ser retornado que o seu verdadeiro nome é ser "${nome}"
    ${bio_name}         Get from Dictionary     ${resposta.json()['biography']}       full-name
    Should Be Equal     ${bio_name}             ${nome}

E deve ser retornado que é afiliado do grupo "${grupo}"
    ${conn_group}       Get from Dictionary     ${resposta.json()['connections']}       group-affiliation
    Should Be True      """${grupo}""" in """${conn_group}"""

Pesquisa heroID
    [Arguments]         ${pesquisa}         ${nome_heroi}
    ${teste}            Get from Dictionary       ${pesquisa.json()['results']['name'=='${nome_heroi}']}    id
    [Return]            ${teste}

Quando requisitar as estatísticas de poder dos super heróis "${nome_heroi_1}" e "${nome_heroi_2}"
    ${req_heroi_1}          Get Request         sessao      /search/${nome_heroi_1}
    ${req_heroi_2}          Get Request         sessao      /search/${nome_heroi_2}
    ${id_heroi_1}           Pesquisa heroID     ${req_heroi_1}      ${nome_heroi_1}
    ${id_heroi_2}           Pesquisa heroID     ${req_heroi_2}      ${nome_heroi_2}
    ${pwrstt_hero_1}        Get Request         sessao      /${id_heroi_1}/powerstats
    ${pwrstt_hero_2}        Get Request         sessao      /${id_heroi_2}/powerstats
    Set Test Variable       ${pwrstt_hero_1}
    Set Test Variable       ${pwrstt_hero_2}
    Set Test Variable       ${req_heroi_1} 
    Set Test Variable       ${req_heroi_2} 

Então deve ser retornado que o mais inteligente é o herói "${nome_heroi}"
    ${nome_heroi_campeao}       Heroi Campeão       ${pwrstt_hero_1}      ${pwrstt_hero_2}       intelligence
    Should Be Equal     ${nome_heroi_campeao}       ${nome_heroi}

E deve ser retornado que o mais rápido é o herói "${nome_heroi}"
    ${velocidade_heroi_1}     Get from Dictionary        ${pwrstt_hero_1.json()}      speed
    ${velocidade_heroi_2}     Get from Dictionary        ${pwrstt_hero_2.json()}      speed

    Run Keyword If      ${velocidade_heroi_1} > ${velocidade_heroi_2}       Should Be Equal         Get Nome do Heroi       ${req_heroi_1}      ${nome_heroi}
    ...     else        Should Be Equal         Get Nome do Heroi       ${req_heroi_2}      ${nome_heroi}

E deve ser retornado que o mais forte é o herói "${nome_heroi}"
    ${forca_heroi_1}     Get from Dictionary        ${pwrstt_hero_1.json()}      strength
    ${forca_heroi_2}     Get from Dictionary        ${pwrstt_hero_2.json()}      strength

    Run Keyword If      ${forca_heroi_1} > ${forca_heroi_2}       Should Be Equal     Get Nome do Heroi   ${req_heroi_1}     ${nome_heroi}
    ...     else        Should Be Equal     Get Nome do Heroi   ${req_heroi_2}     ${nome_heroi}

Get Nome do Heroi
    [Arguments]     ${req_heroi}
    Log             ${req_heroi.json()}
    [Return]        Get from Dictionary         ${req_heroi.json()}         name

Heroi Campeão
    [Arguments]     ${heroi1}       ${heroi2}       ${criterio}
    ${valor_heroi_1}     Get from Dictionary        ${heroi1.json()}      ${criterio}
    ${valor_heroi_2}     Get from Dictionary        ${heroi2.json()}      ${criterio}
    ${nome_heroi_1}      Get Nome do Heroi       ${req_heroi_1}
    ${nome_heroi_2}      Get Nome do Heroi       ${req_heroi_2}
    ${nome_heroi_campeao}=      Run Keyword If      ${valor_heroi_1} > ${valor_heroi_2}        ${nome_heroi_1}
    ...                         else                ${nome_heroi_2}
    [Return]        ${nome_heroi_campeao}
