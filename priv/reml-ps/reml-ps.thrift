namespace py reml

service ReMLService {
  string fit(1:string model,
             2:string x,
             3:string y)

  list<double> predict(1:string model,
                       2:string weights,
                       3:list<i32> vector)
}
