import requests

response = requests.get("http://challenge01.root-me.org/programmation/ch1/")
page = response.content.decode("utf-8")

data = re.findall(r'\d+', page)
U = int(data[5])
premier = int(data[1])
deuxieme = int(data[2])
U0 = int(data[4])

def calculate_sequence_term(n):
    U_sequence = [U0]  # Initialize the sequence with U0
    for i in range(1, n+1):
        term = (premier + U_sequence[i - 1]) + (i * deuxieme)
        U_sequence.append(term)
    return U_sequence[n]

term = calculate_sequence_term(U)
print("U =", term)





import requests
improt re
response = requests.get("http://challenge01.root-me.org/programmation/ch1/")
page = response.content.decode("utf-8")

data = re.findall(r'\d+', page)
U = int(data[5])
premier = int(data[1])
deuxieme = int(data[2])
U0 = int(data[4])


def calculate_sequence_term(n):
    U0  = [8]  # Initialize the sequence with U0
    for i in range(1, n+1):
        term = (premier + U0[i-1]) + (i * deuxieme)
        U0.append(term)
    return U0[n]

term_309129 = calculate_sequence_term(U)
print("U309129 =", term_309129)


def calculate_sequence_term(n):
    U = [8]  # Initialize the sequence with U0
    for i in range(1, n+1):
        term = (29 + U[i-1]) + (i * -21)
        U.append(term)
    return U[n]

term_309129 = calculate_sequence_term(309129)
print("U309129 =", term_309129)
