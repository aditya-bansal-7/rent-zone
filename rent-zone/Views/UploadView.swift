import SwiftUI
import MapKit

struct UploadView: View {
    
    @Environment(AppStore.self) var appStore
    
    var categories: [Category] {
        appStore.categoryStore.categories
    }

    @State private var selectedCategory: Category? = nil
    @State private var selectedCondition = ""
    @State private var selectedSize = ""
    @State private var price = ""
    @State private var description = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    init() {
        // Defer selection setup to onAppear since @Environment isn't available in init
        _selectedCategory = State(initialValue: nil)
    }
    
    let conditions = ["New", "Like New", "Used"]
    let sizes = ["XS", "S", "M", "L", "XL"]
    
    var body: some View {
        NavigationStack{
            
            Form{
                Section{
                    VStack(alignment: .leading){
                        Text("Category")
                            .font(.title2)
                            .bold()
                        
                        Picker("Select the Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.id) { category in
                                Text(category.name).tag(Optional(category))
                            }
                        }
                        .pickerStyle(.menu)
                        
                    }
                    VStack(alignment: .leading){
                        Text("Condition")
                            .font(Font.title2)
                            .bold()
                        
                        Picker("Select Condition", selection: $selectedCondition) {
                            
                            ForEach(conditions, id: \.self) { condition in
                                Text(condition).tag(condition)
                            }
                        }
                        
                    }
                    VStack(alignment: .leading){
                        Text("Size")
                            .font(Font.title2)
                            .bold()
                        
                        Picker("Select Size", selection: $selectedSize) {
                            
                            ForEach(sizes, id: \.self) { size in
                                Text(size).tag(size)
                                
                            }
                        }
                    }
                    VStack(alignment: .leading){
                        Text("Price")
                            .font(Font.title2)
                            .bold()
                        
                        TextField("Enter Price", text: $price)
                        
                    }
                
                VStack(alignment: .leading){
                    Text("Description")
                        .font(Font.title2)
                        .bold()
                    
                    TextField("Describe Your Outfit", text: $description, axis: .vertical)
                        .frame(height: 100, alignment: .topLeading)
                }
                
                VStack(alignment: .leading) {
                    Text("Pick-Up Location")
                        .font(.title2)
                        .bold()
                    
                    ZStack {
                        Map(coordinateRegion: $region)
                            .frame(height: 200)
                            .cornerRadius(15)
                    }
                }
            }
            .onAppear {
                if selectedCategory == nil {
                    selectedCategory = categories.first
                }
            }
            
            Section {
                
                let isFormValid = selectedCategory != nil && !selectedCondition.isEmpty && !selectedSize.isEmpty && !price.isEmpty && !description.isEmpty
                
                Button {
                    //
                } label: {
                    
                    Text("List")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.2))
                        .foregroundStyle(.black)
                        .cornerRadius(30)
                }
                .listRowBackground(Color.clear)
                .disabled(!isFormValid)
            }
        }
    
            .navigationTitle("Provide Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                    //
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.black)
                    }
                }
        
            }
           
        }
    }
}

#Preview {
    UploadView()
        .environment(AppStore())
}
