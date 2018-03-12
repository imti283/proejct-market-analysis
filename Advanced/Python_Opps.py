class Employee:
    def __init__(self,fname,lname,pay):
        self.fname = fname
        self.lname = lname
        self.pay = pay
        self.email = fname + '.' + lname + '@unilever.com'

    def fullname(self):
        return '{} {}'.format(self.fname, self.lname)

emp_1 = Employee('imtiyaz','alam', 50000)
emp_2 = Employee('Sana','imtiyaz', 60000)

print (emp_1.fullname())
print (emp_2.fullname())