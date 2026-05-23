# Fase 4 - BLOCO 35.5 - Build local das imagens instrumentadas

Data: Sat May 23 06:16:11 PM -03 2026

## Objetivo
Validar localmente o build das imagens instrumentadas antes de publicar no ECR ou aplicar no cluster.

## Diagnóstico
A primeira tentativa de build do evaluation-service falhou porque o go.mod passou a exigir Go 1.25.0 após a inclusão das dependências OpenTelemetry, enquanto o Dockerfile ainda usava golang:1.22.

## Correção
O Dockerfile do evaluation-service foi atualizado para usar golang:1.25 no estágio builder.

## Resultado final
- Tag local usada: otel-ae2d3be
- evaluation-service build RC final: 0
- flag-service build: já validado com RC 0 na tentativa anterior.
- targeting-service build: já validado com RC 0 na tentativa anterior.
- Imagem evaluation-service presente: 1
- Imagem flag-service presente: 1
- Imagem targeting-service presente: 1

## Observação
Este bloco não fez push para ECR e não aplicou Kubernetes.

## Dockerfile ajustado
```text
1:FROM golang:1.25 AS builder
```

## Tail build evaluation-service
```text
#3 DONE 0.9s

#2 [internal] load metadata for docker.io/library/golang:1.25
#2 DONE 1.4s

#4 [internal] load .dockerignore
#4 transferring context: 2B done
#4 DONE 0.0s

#5 [stage-1 1/4] FROM docker.io/library/debian:bookworm-slim@sha256:0104b334637a5f19aa9c983a91b54c89887c0984081f2068983107a6f6c21eeb
#5 resolve docker.io/library/debian:bookworm-slim@sha256:0104b334637a5f19aa9c983a91b54c89887c0984081f2068983107a6f6c21eeb done
#5 DONE 0.0s

#6 [internal] load build context
#6 transferring context: 804B done
#6 DONE 0.0s

#7 [builder 1/7] FROM docker.io/library/golang:1.25@sha256:cd05a378aaf011e8056745363e5c40f4f2bef0fa4d9bf19b9c38316079c332ff
#7 resolve docker.io/library/golang:1.25@sha256:cd05a378aaf011e8056745363e5c40f4f2bef0fa4d9bf19b9c38316079c332ff done
#7 sha256:74fefb84c218dc7daaa85940d8400317fb5f04b2ff267d6bc54a82bcf8b39112 0B / 126B 0.2s
#7 sha256:74fefb84c218dc7daaa85940d8400317fb5f04b2ff267d6bc54a82bcf8b39112 126B / 126B 0.2s done
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 0B / 60.24MB 0.3s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 0B / 102.23MB 0.2s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 0B / 67.78MB 0.2s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 0B / 25.63MB 0.2s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 12.58MB / 60.24MB 0.6s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 17.83MB / 60.24MB 0.8s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 20.97MB / 60.24MB 0.9s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 2.10MB / 25.63MB 0.6s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 24.12MB / 60.24MB 1.1s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 5.24MB / 102.23MB 0.9s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 6.29MB / 67.78MB 1.1s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 5.24MB / 25.63MB 0.9s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 28.31MB / 60.24MB 1.4s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 7.34MB / 25.63MB 1.1s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 31.46MB / 60.24MB 1.5s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 10.49MB / 102.23MB 1.4s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 12.58MB / 67.78MB 1.4s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 9.44MB / 25.63MB 1.2s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 16.78MB / 67.78MB 1.7s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 11.53MB / 25.63MB 1.4s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 35.65MB / 60.24MB 1.8s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 13.63MB / 25.63MB 1.5s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 16.78MB / 102.23MB 1.8s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 16.78MB / 25.63MB 1.7s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 39.85MB / 60.24MB 2.1s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 22.02MB / 67.78MB 2.0s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 18.87MB / 25.63MB 1.8s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 20.97MB / 25.63MB 2.0s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 23.07MB / 102.23MB 2.3s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 27.26MB / 67.78MB 2.3s
#7 sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 25.63MB / 25.63MB 2.2s done
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 44.04MB / 60.24MB 2.4s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 0B / 49.31MB 0.2s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 28.31MB / 102.23MB 2.6s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 32.51MB / 67.78MB 2.6s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 47.19MB / 60.24MB 2.9s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 36.70MB / 67.78MB 2.9s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 3.15MB / 49.31MB 0.6s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 34.60MB / 102.23MB 3.2s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 6.29MB / 49.31MB 0.9s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 50.33MB / 60.24MB 3.3s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 40.89MB / 67.78MB 3.3s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 53.48MB / 60.24MB 3.6s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 39.85MB / 102.23MB 3.6s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 10.49MB / 49.31MB 1.4s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 45.09MB / 67.78MB 3.8s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 56.62MB / 60.24MB 4.1s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 45.09MB / 102.23MB 4.1s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 13.63MB / 49.31MB 1.8s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 49.28MB / 67.78MB 4.2s
#7 sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 60.24MB / 60.24MB 4.4s done
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 16.78MB / 49.31MB 2.1s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 50.33MB / 102.23MB 4.5s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 53.48MB / 67.78MB 4.5s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 19.92MB / 49.31MB 2.4s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 57.67MB / 67.78MB 4.8s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 56.62MB / 102.23MB 5.0s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 24.12MB / 49.31MB 2.7s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 62.91MB / 67.78MB 5.3s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 62.91MB / 102.23MB 5.4s
#7 sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 67.78MB / 67.78MB 5.5s done
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 69.21MB / 102.23MB 5.7s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 27.26MB / 49.31MB 3.5s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 74.45MB / 102.23MB 6.5s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 32.51MB / 49.31MB 4.2s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 79.69MB / 102.23MB 6.9s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 35.65MB / 49.31MB 5.1s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 44.04MB / 49.31MB 5.4s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 87.03MB / 102.23MB 7.8s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 49.28MB / 49.31MB 5.6s
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 99.61MB / 102.23MB 8.1s
#7 sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 49.31MB / 49.31MB 5.6s done
#7 extracting sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96
#7 sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 102.23MB / 102.23MB 8.2s done
#7 extracting sha256:f32f49ce655a9cf7c1fd4ca1417ddb39a54cedf4b7ff35de20f8009c18dd7a96 0.8s done
#7 DONE 8.8s

#7 [builder 1/7] FROM docker.io/library/golang:1.25@sha256:cd05a378aaf011e8056745363e5c40f4f2bef0fa4d9bf19b9c38316079c332ff
#7 extracting sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471
#7 extracting sha256:8a7504cd2818ce40ac76c17886a03dff25ef0aa06ff6125bf0f0c7302cdc6471 0.3s done
#7 DONE 9.2s

#7 [builder 1/7] FROM docker.io/library/golang:1.25@sha256:cd05a378aaf011e8056745363e5c40f4f2bef0fa4d9bf19b9c38316079c332ff
#7 extracting sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba
#7 extracting sha256:b53089dca50590292ecc77bf803152a5799650e734717e4b706cb812a02073ba 1.0s done
#7 DONE 10.1s

#7 [builder 1/7] FROM docker.io/library/golang:1.25@sha256:cd05a378aaf011e8056745363e5c40f4f2bef0fa4d9bf19b9c38316079c332ff
#7 extracting sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4
#7 extracting sha256:53a98c547303546d38e1c9037e220e2f2e0cd3a0d9116b0a420b916d4af2ecb4 1.3s done
#7 DONE 11.5s

#7 [builder 1/7] FROM docker.io/library/golang:1.25@sha256:cd05a378aaf011e8056745363e5c40f4f2bef0fa4d9bf19b9c38316079c332ff
#7 extracting sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429
#7 extracting sha256:212f1aa7b6f145e07f32d904940cd57ec172ed8397de9151cdcbb21d82522429 1.5s done
#7 DONE 13.0s

#7 [builder 1/7] FROM docker.io/library/golang:1.25@sha256:cd05a378aaf011e8056745363e5c40f4f2bef0fa4d9bf19b9c38316079c332ff
#7 extracting sha256:74fefb84c218dc7daaa85940d8400317fb5f04b2ff267d6bc54a82bcf8b39112 done
#7 extracting sha256:4f4fb700ef54461cfa02571ae0db9a0dc1e0cdb5577484a6d75e68dc38e8acc1 done
#7 DONE 13.0s

#8 [builder 2/7] WORKDIR /app
#8 DONE 0.1s

#9 [builder 3/7] COPY go.mod ./
#9 DONE 0.0s

#10 [builder 4/7] COPY go.sum* ./
#10 DONE 0.0s

#11 [builder 5/7] RUN go mod download || true
#11 DONE 7.0s

#12 [builder 6/7] COPY . .
#12 DONE 0.2s

#13 [builder 7/7] RUN go build -o service .
#13 DONE 19.8s

#14 [stage-1 2/4] WORKDIR /app
#14 CACHED

#15 [stage-1 3/4] RUN apt-get update  && apt-get install -y --no-install-recommends       ca-certificates       curl  && rm -rf /var/lib/apt/lists/*
#15 CACHED

#16 [stage-1 4/4] COPY --from=builder /app/service /app/service
#16 DONE 0.0s

#17 exporting to image
#17 exporting layers
#17 exporting layers 0.6s done
#17 exporting manifest sha256:cddd5b0e048ca65bbdcc9dae609b99fbae62df2f5100a32b27619800d606b6dc done
#17 exporting config sha256:61d383ed703b471b153ebb4541e7feac353e7622676e1884914c7f4217d4c323 done
#17 exporting attestation manifest sha256:da03e5e61e8f2376b7ab52ae9f4acca519157b030b81bec748848be7d6b270d6 done
#17 exporting manifest list sha256:2f6f20bb020498f6bf29625e9766ab30b40ed8c6229dcf8beaad163d629944a0 done
#17 naming to docker.io/togglemaster/evaluation-service:otel-ae2d3be done
#17 unpacking to docker.io/togglemaster/evaluation-service:otel-ae2d3be 0.1s done
#17 DONE 0.7s
```

## Imagens locais
```text
togglemaster/evaluation-service:otel-ae2d3be                                               2f6f20bb0204        176MB         46.8MB        
togglemaster/flag-service:otel-ae2d3be                                                     1c403a88dc24        560MB          145MB        
togglemaster/targeting-service:otel-ae2d3be                                                a5bc3585bd65        560MB          145MB        
```

## Próximo passo
Publicar as três imagens instrumentadas no ECR, atualizar GitOps com a nova tag e validar traces reais no OTel Collector.
