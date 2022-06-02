
class Todo {

  int id;
  String name;
  bool checked;
  int parentId;

  Todo(this.id,this.name,this.checked,this.parentId);



  static Todo fromMap(Map<String, dynamic> todoMap){
    if(todoMap==null){
      return null;
    }else{
      return Todo(todoMap["i"],todoMap["n"],todoMap["c"]==1?true:false,todoMap["p"]);
    }
  }

  Map<String,dynamic> toMap(){
    return {
      "i" : id,
      "n" : name,
      "c" : checked?1:0,
      "p" : parentId,
    };
  }

  static List<Todo> getTodosFromMap(List<dynamic> todos){
    List<Todo> todosToReturn = List();

    if(todos==null){
      return todosToReturn;
    }
    print(todos);
    
    todos.forEach((v){
      Todo todo = Todo.fromMap(v);
      todosToReturn.add(todo);
    });

    return todosToReturn;

  }

  Todo getCopy(int id) {
    return Todo(id, "Copy of: $name", checked, parentId);
  }

}

//  class TreeNode {
//   static const int UNDEFINE = -1;


//   Todo content;
//   TreeNode parent;
//   List<TreeNode> childList;
//   bool isExpand;

//   TreeNode(this.content);

//   int getHeight(){return parent==null?0:parent.getHeight() + 1;}

//   static int getAllChildCountIfExpanded(TreeNode treeNode){
//       int allChildSize = treeNode.childList.length;

//       if (treeNode.isExpand){
//         treeNode.childList.forEach((item){
//           allChildSize = allChildSize+getAllChildCountIfExpanded(treeNode);
//         });
//       }


//       return allChildSize;
//   }


//   int getAllChildsSize(){
//       return getAllChildCountIfExpanded(this);
//   }

//   bool isLeaf() {
//       return childList == null || childList.isEmpty;
//   }

//   void collapseAll() {
//       isExpand = false;
//       if (childList == null || childList.isEmpty) {
//           return;
//       }
//       childList.forEach((item){
//         item.collapseAll();
//       });
//   }


//   void expandAll() {
//       isExpand = true;
//       if (childList == null || childList.isEmpty) {
//           return;
//       }
//       childList.forEach((item){
//         item.expandAll();
//       });
//   }


//   //
//   //
//   //
//   //
//   //
//   //

//   @Transaction
//         List<TreeNode> loadSortedTodos(boolean forToday){

//             List<TreeNode> unSortedTodos = new ArrayList<>();

//             for (Todo todoWithoutParent: getTodosWithParrentId(-1,forToday)){

//                 unSortedTodos.add(getTreenodeFromTodo(todoWithoutParent,forToday));
//             }

//             return findDisplayNodes(unSortedTodos);
//         }

//     private TreeNode getTreenodeFromTodo(Todo todoWithoutParent,bool isForToday) {

//         TreeNode treeNode =new TreeNode(todoWithoutParent);


//             for (Todo todo:getTodosWithParrentId(todoWithoutParent.id,isForToday)){

//                 if (todo!=null){
//                     treeNode.addChild(getTreenodeFromTodo(todo,isForToday));
//                 }


//             }


//         return treeNode;
//     }

//     private List<TreeNode> findDisplayNodes(List<TreeNode> nodes) {


//             List<TreeNode> sortedTodos = new ArrayList<>();



//         for (TreeNode node : nodes) {
//             sortedTodos.add(node);
//             if (!node.isLeaf())
//                 findDisplayNodes(node.getChildList());
//         }

//         return sortedTodos;
//     }

//   getTodosWithParrentId(int id, bool isForToday) {
    
//   }



// }