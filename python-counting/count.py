# Couting in Python

print("Counting in Python")

# Counting from 1 to 10
for i in range(1, 11):
    print(i)

numbers = [1,2,3,4,5,6,7,8,9,10]
evens = [x for x in numbers if x % 2 == 0]
print(evens)