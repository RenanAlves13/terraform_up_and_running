# Terraform Up & Running - Exemplos de Código

Este repositório contém os exemplos práticos e códigos extraídos do livro **[Terraform Up & Running](https://www.amazon.com.br/Terraform-Running-English-Yevgeniy-Brikman-ebook/dp/B0BFVT6XS4/)**, de **Yevgeniy Brikman**.  
O objetivo é fornecer um guia prático para aprender e aplicar **Infrastructure as Code (IaC)** usando o **Terraform**.

---

## 📚 Sobre o Livro

O livro *Terraform Up & Running* é uma introdução prática ao Terraform, uma das ferramentas mais populares para provisionamento e gerenciamento de infraestrutura em nuvem.  
Ele cobre desde conceitos básicos até práticas avançadas, incluindo:

- Provisionamento de recursos simples
- Uso de módulos e reutilização de código
- Deploy de aplicações escaláveis e seguras
- Boas práticas de organização, testes e manutenção
- Estratégias de trabalho em equipe e automação

---

## 📂 Estrutura do Repositório

Cada diretório corresponde a exemplos apresentados em diferentes capítulos do livro:
---

## ⚙️ Pré-requisitos

Antes de começar, você precisará ter instalado:

- [Terraform](https://www.terraform.io/downloads) (>= 1.0 recomendado)
- Conta na [AWS](https://aws.amazon.com/) ou outro provedor suportado
- [AWS CLI](https://docs.aws.amazon.com/cli/) configurada (opcional, mas recomendado)

Configure suas credenciais AWS:

```bash
export AWS_ACCESS_KEY_ID="sua-access-key"
export AWS_SECRET_ACCESS_KEY="sua-secret-key"
export AWS_DEFAULT_REGION="us-east-2"
