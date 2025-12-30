import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/budget_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc({required this.categoryRepository}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadDefaultCategories>(_onLoadDefaultCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading());
      final categories = await categoryRepository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to load categories: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDefaultCategories(
    LoadDefaultCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading());
      final categories = await categoryRepository.getDefaultCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to load default categories: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await categoryRepository.createCategory(event.category);
      emit(const CategoryOperationSuccess('Category created successfully'));
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Failed to create category: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await categoryRepository.updateCategory(event.category);
      emit(const CategoryOperationSuccess('Category updated successfully'));
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Failed to update category: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await categoryRepository.deleteCategory(event.categoryId);
      emit(const CategoryOperationSuccess('Category deleted successfully'));
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Failed to delete category: ${e.toString()}'));
    }
  }
}
